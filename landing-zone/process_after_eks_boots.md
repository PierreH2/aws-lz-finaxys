# Process après bootstrap EKS (agentic-research-eks)

Ce document formalise les actions nécessaires pour:

- autoriser un compte/rôle IAM à administrer le cluster EKS,
- rendre le cluster exploitable pour des workloads Fargate + exposition ALB,

---

## 1) Autoriser un rôle IAM à administrer EKS

### Contexte

Même avec un kubeconfig valide, `kubectl` peut échouer avec `You must be logged in to the server` si le principal IAM n'a pas d'accès EKS/RBAC.

### Commandes appliquées

```bash
aws eks update-kubeconfig \
	--name agentic-research-eks \
	--region eu-west-1 \
	--role-arn arn:aws:iam::333320350721:role/OrganizationAccountAccessRole

aws eks create-access-entry \
	--cluster-name agentic-research-eks \
	--region eu-west-1 \
	--principal-arn arn:aws:iam::333320350721:role/OrganizationAccountAccessRole

aws eks associate-access-policy \
	--cluster-name agentic-research-eks \
	--region eu-west-1 \
	--principal-arn arn:aws:iam::333320350721:role/OrganizationAccountAccessRole \
	--policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
	--access-scope type=cluster
```

Important:

- `aws eks update-kubeconfig` ne donne pas les droits Kubernetes à lui seul,
- il configure seulement l'authentification (token AWS IAM),
- l'autorisation dans le cluster (RBAC) doit ensuite être accordée.

Dans notre cas, les 2 commandes `aws eks create-access-entry` + `aws eks associate-access-policy` ont servi à **lier le rôle IAM** `OrganizationAccountAccessRole` à des permissions Kubernetes internes (cluster-admin via politique EKS gérée). Sans cette étape, l'API EKS répond mais refuse les actions `kubectl`.

### Vérification

```bash
kubectl get ns
```

---

## 2) Déploiements/config nécessaires au bon fonctionnement cible (Fargate + EFS + ALB)

### 2.1 Endpoint API EKS accessible depuis le poste d'admin

Pour exécuter `kubectl` depuis l'extérieur du VPC, l'endpoint public EKS doit être activé.

Configuration Terraform appliquée (`landing-zone/eks.tf`):

- `cluster_endpoint_public_access = true`
- `cluster_endpoint_private_access = true`
- `cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs`

Vérification:

```bash
aws eks describe-cluster \
	--name agentic-research-eks \
	--region eu-west-1 \
	--query 'cluster.resourcesVpcConfig.{public:endpointPublicAccess,private:endpointPrivateAccess}'
```

### 2.2 Stockage persistant compatible Fargate

Fargate ne supporte pas EBS pour les pods applicatifs. Il faut EFS.

### 2.3 CoreDNS sur Fargate

CoreDNS est un composant DNS interne du cluster Kubernetes.

- Sur EKS, il est fourni automatiquement comme composant système (add-on EKS / déploiement dans `kube-system`).
- Il est indispensable: résolution DNS des services (`*.svc.cluster.local`), appels inter-services, résolution externe depuis les pods.

Il peut arriver que Coredns bloque en pending car il ne comprend pas qu'il est sur Fargate.

Correctif appliqué:

```bash
kubectl patch deployment coredns -n kube-system --type merge \
	-p '{"spec":{"template":{"metadata":{"annotations":{"eks.amazonaws.com/compute-type":"fargate"}}}}}'

kubectl rollout restart deployment coredns -n kube-system
```

### 2.4 AWS Load Balancer Controller (obligatoire pour Ingress ALB)

Sans ce controller, un `Ingress` annoté ALB ne crée aucun load balancer.

Actions appliquées:

- création/usage de la policy IAM `AWSLoadBalancerControllerIAMPolicy`,
- création/usage du rôle IRSA `AmazonEKSLoadBalancerControllerRole`,
- installation du chart Helm `aws-load-balancer-controller` dans `kube-system`,
- attachement du ServiceAccount `aws-load-balancer-controller` au rôle IAM.

Validation:

```bash
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system
kubectl get ingress web-alb-test-ingress -n default -o wide
```

## 3) Checklist rapide post-déploiement

```bash
kubectl get pods -A
kubectl get pvc,pv -n default
kubectl get ingress web-alb-test-ingress -n default -o wide
curl -I http://$(kubectl get ingress web-alb-test-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Commande explicite pour récupérer uniquement l'URL ALB dynamique:

```bash
echo "http://$(kubectl get ingress web-alb-test-ingress -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```
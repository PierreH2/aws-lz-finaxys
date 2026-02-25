# Déploiement de la Landing Zone AWS

1. **Démarrer par le dossier `bootstrap-aws-account/`**
	- Connectez-vous avec un compte AWS parent/root (via AWS CLI avec : aws login).
	- Lancez `terraform init` `terraform plan` puis `terraform apply` dans ce dossier pour créer un nouveau compte AWS Organization et appliquer les SCP.
	- Vous pouvez récupérer l'ID du compte créer avec terraform output

2. **Se connecter au nouveau compte créé**
	- Utilisez le rôle IAM (ex: `OrganizationAccountAccessRole`) pour assumer le compte.

3. **Déployer les autres dossiers**
	- Passez dans `bootstrap-s3/` puis `landing-zone/` et lancez Terraform dans chacun, en utilisant le compte nouvellement créé.

> Respectez cet ordre pour garantir la bonne initialisation de l'environnement AWS.
# AWS Landing Zone

Infrastructure AWS simple avec VPC hybride, un EKS Fargate et tous les composant nécessaire à l'EKS Fargate (ECR, ALB, EFS ...)

## Structure

```
aws-lz/
├── bootstrap-aws-account/          # aws organization account + SCP
├── bootstrap-s3/                 # Backend S3 bootstrap
├── landing-zone/                 # VPC hybride
└── after_eks_deployment/                # Configuration de EKS Fargate + exposition ALB
```

## Prérequis

- **Terraform 1.10+** (pour verrouillage natif S3, pas de DynamoDB nécessaire)
- AWS CLI configuré
- kubectl
- helm

## Dossier test_manifest

Le dossier `test_manifest/` contient des fichiers prêts à l'emploi pour valider le chemin complet:

- push d'une image de test DockerHub vers votre repository ECR,
- déploiement sur EKS Fargate,
- exposition du service via un ALB (Ingress).

Fichiers principaux:

- `after_eks_deployment/test_manifest/docker_push.sh` : pull/tag/push de l'image vers ECR,
- `after_eks_deployment/test_manifest/manifest.yaml` : manifest Kubernetes (PV/PVC, Deployment, Service, Ingress ALB),
- `after_eks_deployment/est_manifest/deploy_manifest.sh` : update kubeconfig EKS puis `kubectl apply`.

## Scripts

### aws-login.sh
Vérification de la connexion AWS (détecte automatiquement profil et région)
```bash
./aws-login.sh
```

### terraform-workflow.sh
Workflow Terraform en 2 étapes (fmt/validate/plan puis demande de confirmation)
```bash
./terraform-workflow.sh bootstrap/
# Répond 'y' pour appliquer ou 'n' pour annuler
```

### profil AWS

Le script `aws-login.sh` détecte automatiquement votre configuration AWS.

## Nettoyage

important: Il faut supprimer toute les ressources kubernetes avant de faire terraform destroy afin d'éviter une dependency deadlock (car terraform ne peut pas supprimer les ressources provisioné par kubernetes directement (ex: les ENI des ALB dynamiques))

important: il faut supprimer toute les images de l'ECR si possible sinon mettre un force destroy.

```bash
cd landing-zone/ && terraform destroy
```

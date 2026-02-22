# Déploiement de la Landing Zone AWS

1. **Démarrer par le dossier `bootstrap-aws-account/`**
	- Connectez-vous avec un compte AWS parent/root (via AWS SSO ou CLI).
	- Lancez `terraform apply` dans ce dossier pour créer un nouveau compte AWS Organization et appliquer les SCP.
	- Notez l'ID du compte créé et le rôle IAM.

2. **Se connecter au nouveau compte créé**
	- Utilisez le rôle IAM (ex: `OrganizationAccountAccessRole`) pour assumer le compte.

3. **Déployer les autres dossiers**
	- Passez dans `bootstrap-s3/` puis `landing-zone/` et lancez Terraform dans chacun, en utilisant le compte nouvellement créé.

> Respectez cet ordre pour garantir la bonne initialisation de l'environnement AWS.
# AWS Landing Zone

Infrastructure AWS simple avec VPC hybride et backend Terraform.

## Structure

```
aws-lz/
├── bootstrap-aws-account/          # aws organization account + SCP
├── bootstrap-s3/                 # Backend S3 bootstrap
├── landing-zone/                 # VPC hybride
└── test_manifest/                # Image de test ECR + déploiement EKS Fargate + exposition ALB
```

## Dossier test_manifest

Le dossier `test_manifest/` contient des fichiers prêts à l'emploi pour valider le chemin complet:

- push d'une image de test DockerHub vers votre repository ECR,
- déploiement sur EKS Fargate,
- exposition du service via un ALB (Ingress).

Fichiers principaux:

- `test_manifest/docker_push.sh` : pull/tag/push de l'image vers ECR,
- `test_manifest/manifest.yaml` : manifest Kubernetes (PV/PVC, Deployment, Service, Ingress ALB),
- `test_manifest/deploy_manifest.sh` : update kubeconfig EKS puis `kubectl apply`.

## Prérequis

- **Terraform 1.10+** (pour verrouillage natif S3, pas de DynamoDB nécessaire)
- AWS CLI configuré


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

```bash
cd landing-zone/ && terraform destroy
```

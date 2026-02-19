# Déploiement de la Landing Zone AWS

1. **Démarrer par le dossier `bootstrap-aws-account/`**
	- Connectez-vous avec un compte AWS parent/root (via AWS SSO ou CLI).
	- Lancez `terraform apply` dans ce dossier pour créer un nouveau compte AWS Organization et appliquer les SCP.
	- Notez l'ID du compte créé et le rôle IAM.

2. **Se connecter au nouveau compte créé**
	- Utilisez le rôle IAM (ex: `OrganizationAccountAccessRole`) pour assumer le compte.

3. **Déployer les autres dossiers**
	- Passez dans `bootstrap-s3-oidc/` puis `landing-zone/` et lancez Terraform dans chacun, en utilisant le compte nouvellement créé.

> Respectez cet ordre pour garantir la bonne initialisation de l'environnement AWS.
# AWS Landing Zone

Infrastructure AWS simple avec VPC hybride et backend Terraform.

## Structure

```
aws-lz/
├── bootstrap/          # Backend S3 + OIDC GitHub
└── landing-zone/       # VPC hybride
```

## Prérequis

- **Terraform 1.10+** (pour verrouillage natif S3, pas de DynamoDB nécessaire)
- AWS CLI configuré

## Déploiement

### 1. Bootstrap

```bash
aws login
# Vérifier la connexion AWS
./aws-login-verification.sh

# Déployer le backend
cd bootstrap/
terraform init
terraform apply
# Noter le nom du bucket S3 dans les outputs
cd ..
```

### 2. Landing Zone

Éditer `landing-zone/providers.tf` et décommenter le backend S3 avec le nom du bucket obtenu.

```bash
cd landing-zone/
terraform init
terraform apply
```

## VPC Hybride

- **CIDR**: 10.0.0.0/16
- **2 sous-réseaux publics** (10.0.0.0/24, 10.0.1.0/24)
- **2 sous-réseaux privés** (10.0.2.0/24, 10.0.3.0/24)
- **Internet Gateway** pour accès public
- **NAT Gateway** pour accès internet depuis privé

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

## Configuration

### Profil et Région AWS

Le script `aws-login.sh` détecte automatiquement votre configuration AWS.

Pour configurer ou changer votre région :
```bash
aws configure set region eu-north-1
```

Ou utiliser une variable d'environnement :
```bash
export AWS_REGION=eu-north-1
```

### Variables Terraform

Variables dans `landing-zone/`:
- `aws_region` (défaut: eu-north-1)
- `project_name` (défaut: aws-lz)
- `vpc_cidr` (défaut: 10.0.0.0/16)

## Nettoyage

```bash
cd landing-zone/ && terraform destroy
cd ../bootstrap/ && terraform destroy
```

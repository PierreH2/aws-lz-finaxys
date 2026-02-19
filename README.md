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
├── bootstrap-aws-account/          # aws organization account + SCP
├── bootstrap-s3-oidc/          # Backend S3 + OIDC GitHub
└── landing-zone/       # VPC hybride
```

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

## Nettoyage

```bash
cd landing-zone/ && terraform destroy
cd ../bootstrap/ && terraform destroy
```

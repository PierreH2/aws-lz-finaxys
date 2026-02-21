## Post-Mortem : Migration du state local vers S3

J'ai oublié de créer un bucket s3 et terraform a donc géré un bucket s3 en local. La suite de ce .md partage la migration du tfstate local dans un bucket s3.

0. Ajouter les fichiers .tf initiant le bucket s3 (backend.tf & state_backend.tf)

1. Désactiver temporairement le backend S3 puis initialiser en local (pour pouvoir créer le bucket S3) :

```bash
aws login
mv backend.tf backend.tf.disabled
terraform init
terraform apply
```

2. Réactiver le backend S3 puis migrer le state local :

```bash
BUCKET_NAME=$(terraform output -raw tfstate_bucket_name)
STATE_KEY=$(terraform output -raw tfstate_backend_key)
mv backend.tf.disabled backend.tf

# Vérifier/initialiser les credentials AWS (adapter le profil si nécessaire)
aws sts get-caller-identity --profile default || aws sso login --profile default

eval "$(aws configure export-credentials --profile default --format env)"

AWS_EC2_METADATA_DISABLED=true 

terraform init 
  -migrate-state \
  -backend-config="bucket=${BUCKET_NAME}" \
  -backend-config="key=${STATE_KEY}" \
  -backend-config="region=eu-north-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"
```

3. Vérifier :

```bash
terraform state pull > /dev/null && echo "Backend S3 OK"
```

## Variables utiles

- `tfstate_bucket_name` : nom du bucket backend Terraform.
- `tfstate_region` : région du bucket backend Terraform.
- `tfstate_key` : chemin du fichier state dans le bucket S3.

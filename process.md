# Processus complet de déploiement AWS Landing Zone & Application

## 1. Créer le compte AWS d'atterrissage (Landing Zone)
- Se connecter avec un compte AWS parent/root (via AWS login puis eval "$(aws configure export-credentials --profile default --format env)").
- Aller dans `bootstrap-aws-account/`.
- Renseigner les variables (nom, email, etc.) dans `terraform.tfvars` ou via CLI.
- Lancer :
  ```sh
  terraform init
  terraform plan
  terraform apply
  ```
- Noter l'ID du compte et le rôle IAM créé.

## 2. Se connecter au nouveau compte créé
- Récupérer les outputs Terraform du compte créé :
  ```sh
  cd bootstrap-aws-account
  terraform output account_id
  terraform output account_arn
  ```
- Modifier `~/.aws/config` pour ajouter le profil d'assume role :
  ```ini
  [profile finaxys-lz]
  role_arn = arn:aws:iam::<ACCOUNT_ID>:role/OrganizationAccountAccessRole
  source_profile = default
  region = eu-west-1
  role_session_name = tf-bootstrap
  ```
- Exporter les credentials de la session sur ce profil :
  ```sh
  eval "$(aws configure export-credentials --profile finaxys-lz --format env)"
  aws sts get-caller-identity
  ```

## 3. Initialiser l'infra cloud native
- Aller dans `bootstrap-s3-oidc/` puis `landing-zone/` (dans cet ordre).
- Dans chaque dossier :
  ```sh
  terraform init
  terraform apply
  ```

## 4. Builder et pousser une image Docker dans ECR
- Builder l'image :
  ```sh
  docker build -t myapp:latest .
  ```
- Récupérer l'URL du repo ECR (output Terraform ou AWS Console).
- Taguer et pousser :
  ```sh
  aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
  docker tag myapp:latest <account-id>.dkr.ecr.<region>.amazonaws.com/myapp:latest
  docker push <account-id>.dkr.ecr.<region>.amazonaws.com/myapp:latest
  ```

## 5. Déployer l'application sur EKS
- Récupérer le kubeconfig du cluster EKS (output Terraform ou AWS Console) :
  ```sh
  aws eks update-kubeconfig --region <region> --name <cluster-name>
  ```
- Créer un manifest Kubernetes (exemple) :
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: myapp
    namespace: default
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: myapp
    template:
      metadata:
        labels:
          app: myapp
      spec:
        containers:
          - name: myapp
            image: <account-id>.dkr.ecr.<region>.amazonaws.com/myapp:latest
            ports:
              - containerPort: 8000
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: myapp
  spec:
    type: LoadBalancer
    selector:
      app: myapp
    ports:
      - protocol: TCP
        port: 80
        targetPort: 8000
  ```
- Appliquer le manifest :
  ```sh
  kubectl apply -f myapp.yaml
  ```

## 6. Accéder à l'application
- Récupérer l'adresse du LoadBalancer (NLB) :
  ```sh
  kubectl get svc myapp
  ```
- Utiliser l'EXTERNAL-IP ou le DNS affiché pour accéder à l'application depuis Internet.

---

**Résumé** :
1. Créer le compte d'atterrissage avec SCP.
2. Se connecter au compte créé.
3. Déployer l'infra cloud native (S3, OIDC, EKS, ECR, NLB, etc.).
4. Builder/pousser l'image Docker dans ECR.
5. Déployer l'app sur EKS avec un Service LoadBalancer.
6. Accéder à l'app via l'IP/hostname du NLB.

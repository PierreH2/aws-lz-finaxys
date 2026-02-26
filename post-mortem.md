# Post-mortem : Déploiement sur EKS Fargate

## Contexte
Déploiement d’une application AI/ML (agentic-research) sur AWS EKS Fargate, avec besoin d’exposition internet et de stockage persistant.

## Problèmes rencontrés

1. **Déploiement complexe et contraintes réseau**
   - Fargate ne supporte que les subnets privés.
   - Pour exposer un service, il faut obligatoirement un ALB (Application Load Balancer) en subnet public, ce qui ajoute de la complexité (IAM, security groups, routage, etc).

2. **ALB Controller obligatoire**
   - Nécessité de déployer le controller AWS Load Balancer Controller (via Helm) pour gérer les Ingress/ALB.
   - Ajoute une dépendance, de la configuration IAM/OIDC, et des ressources supplémentaires à maintenir.

3. **Pas de provisionnement dynamique de volumes**
   - Fargate ne supporte pas le provisionnement dynamique EFS (pas de CSI controller possible sur Fargate-only).
   - Seule option : créer manuellement un access point EFS et un PV statique, ce qui est lourd et peu flexible.

4. **Limite de 10 Go d’espace disque par pod**
   - L’espace disque éphémère par pod est limité (~10 Go effectifs).
   - Impossible de déployer des images Docker volumineuses (>10 Go), ce qui a bloqué le use case AI/ML.

## Conséquence
- Le déploiement sur Fargate s’est avéré trop contraignant et inadapté pour ce type d’application.
- Les limitations sur le stockage et la gestion réseau ont tué le use case.

## Solution retenue
- **Migration vers EKS sur nodes EC2 managés** :
  - Plus de flexibilité sur la taille disque, le stockage persistant (EFS dynamique OK), et la gestion réseau.
  - Déploiement plus classique, mieux documenté, et plus robuste pour les workloads AI/ML.
  - Moins “finops” (coût minimal par pod moins optimisé), mais bien plus fiable pour ce besoin.

## TL;DR
EKS Fargate = bon pour microservices stateless simples, trop limité pour workloads AI/ML ou tout ce qui a besoin de stockage persistant ou d’images lourdes.

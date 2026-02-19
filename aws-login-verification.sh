#!/bin/bash
# Vérification de la connexion AWS

set -e

echo "=== Vérification AWS ===="

# Vérifier AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI non installé"
    exit 1
fi

# Détecter le profil actuel
CURRENT_PROFILE="${AWS_PROFILE:-$(aws configure list | grep profile | awk '{print $2}')}"
if [ -z "$CURRENT_PROFILE" ] || [ "$CURRENT_PROFILE" = "<not" ]; then
    CURRENT_PROFILE="default"
fi

# Détecter la région actuelle
CURRENT_REGION="${AWS_REGION:-$(aws configure get region 2>/dev/null)}"
if [ -z "$CURRENT_REGION" ]; then
    CURRENT_REGION="non configurée"
fi

echo "Profile détecté: $CURRENT_PROFILE"
echo "Région détectée: $CURRENT_REGION"
echo ""

# Vérifier la connexion
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Non connecté à AWS"
    echo "Lancez: aws configure"
    exit 1
fi

# Récupérer les infos du compte
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
REAL_REGION=$(aws configure get region 2>/dev/null || echo "non définie")

echo "✅ Connecté à AWS"
echo ""
echo "Account ID: $ACCOUNT_ID"
echo "User/Role:  $USER_ARN"
echo "Région:     $REAL_REGION"
echo ""
echo "✓ Prêt pour Terraform"



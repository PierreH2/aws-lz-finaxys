#!/bin/bash
# Workflow Terraform en deux étapes
# Usage: ./terraform-workflow.sh [directory]

set -e

TF_DIR="${1:-.}"
cd "$TF_DIR"

echo "=== Terraform Workflow ==="
echo "Directory: $(pwd)"
echo ""

# === ÉTAPE 1: Préparation ===
echo "--- Étape 1: Préparation ---"
echo ""

echo "→ Format..."
terraform fmt -recursive

echo "→ Init..."
terraform init -upgrade

echo "→ Validate..."
terraform validate

echo "→ Plan..."
terraform plan -out=tfplan

echo ""
echo "✅ Préparation terminée"
echo ""

# === ÉTAPE 2: Demande de confirmation ===
echo "--- Étape 2: Application ---"
echo ""
read -p "Voulez-vous appliquer ces changements ? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "→ Apply..."
    terraform apply tfplan
    rm -f tfplan
    echo ""
    echo "✅ Déploiement terminé"
else
    echo ""
    echo "❌ Application annulée"
    echo "Pour appliquer plus tard: terraform apply tfplan"
    exit 0
fi


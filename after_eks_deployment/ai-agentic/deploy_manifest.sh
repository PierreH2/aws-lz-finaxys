#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== Deploying agentic-research to EKS ==="

kubectl apply -f manifest/00-namespace.yaml

# Create secret if it doesn't exist (requires OPENAI_API_KEY env var)
if ! kubectl -n ai-agentic get secret agentic-research-secrets &>/dev/null; then
  if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    echo "ERROR: Set OPENAI_API_KEY env var before deploying (secret does not exist yet)"
    exit 1
  fi
  kubectl create secret generic agentic-research-secrets \
    --namespace ai-agentic \
    --from-literal=OPENAI_API_KEY="$OPENAI_API_KEY"
  echo "Secret created."
else
  echo "Secret already exists, skipping."
fi

kubectl apply -f manifest/02-storage.yaml
kubectl apply -f manifest/03-dataprep.yaml
kubectl apply -f manifest/04-agentic-research.yaml

echo ""
echo "=== Done. Checking rollout status ==="
kubectl -n ai-agentic rollout status deployment/dataprep --timeout=120s
kubectl -n ai-agentic rollout status deployment/agentic-research --timeout=120s

echo ""
echo "=== Ingress ==="
kubectl -n ai-agentic get ingress agentic-research-ingress

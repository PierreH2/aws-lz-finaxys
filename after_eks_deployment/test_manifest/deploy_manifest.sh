#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGION="${AWS_REGION:-eu-west-1}"
CLUSTER="${EKS_CLUSTER:-agentic-research-eks}"
ACCOUNT_ID="333320350721"
EFS_ID="${EFS_FILE_SYSTEM_ID:-fs-05d8ae41fd4abde6a}"
NAMESPACE="test"
MANIFEST="${1:-${SCRIPT_DIR}/manifest.yaml}"

# --- Pre-checks ---
for cmd in aws kubectl; do
  command -v "$cmd" >/dev/null || { echo "$cmd is required."; exit 1; }
done

[[ -f "$MANIFEST" ]] || { echo "Manifest not found: $MANIFEST"; exit 1; }

CURRENT_ACCOUNT="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
[[ "$CURRENT_ACCOUNT" == "$ACCOUNT_ID" ]] || {
  echo "AWS account mismatch: expected $ACCOUNT_ID, got ${CURRENT_ACCOUNT:-unknown}."
  exit 1
}

# --- Template EFS ID if needed ---
RENDERED="$MANIFEST"
if grep -q "fs-REPLACE_ME" "$MANIFEST"; then
  [[ "$EFS_ID" =~ ^fs-[a-z0-9]+$ ]] || { echo "Invalid EFS ID: $EFS_ID"; exit 1; }
  RENDERED="$(mktemp)"
  trap 'rm -f "$RENDERED"' EXIT
  sed "s/fs-REPLACE_ME/${EFS_ID}/g" "$MANIFEST" > "$RENDERED"
fi

# --- Deploy ---
echo "Configuring kubeconfig for $CLUSTER ($REGION)..."
aws eks update-kubeconfig --name "$CLUSTER" --region "$REGION"

echo "Applying $RENDERED..."
kubectl apply -f "$RENDERED"

echo "Waiting for rollout..."
kubectl rollout status deployment/web-alb-test -n "$NAMESPACE" --timeout=300s

echo "Ingress:"
kubectl get ingress web-alb-test-ingress -n "$NAMESPACE"

echo "Done."

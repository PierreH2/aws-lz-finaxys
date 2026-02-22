#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_MANIFEST_PATH="${SCRIPT_DIR}/manifest.yaml"
DEFAULT_TF_DIR="${SCRIPT_DIR}/../landing-zone"
DEFAULT_REGION="eu-west-1"
DEFAULT_CLUSTER_NAME="agentic-research-eks"
EXPECTED_AWS_ACCOUNT_ID="333320350721"
EXPECTED_EKS_ENDPOINT="https://2E8D7ACA3DC9092524F2DB88FB425EC6.gr7.eu-west-1.eks.amazonaws.com"
ECR_REPOSITORY_URL="333320350721.dkr.ecr.eu-west-1.amazonaws.com/agentic-research"
EFS_FILE_SYSTEM_ID="fs-0ad7b814ce04d09cb"
EFS_SECURITY_GROUP_ID="sg-01433008e8dda7a81"
VPC_ID="vpc-098127d3fe791be90"
CLUSTER_SECURITY_GROUP_ID="sg-0b3655fca6a848179"
FARGATE_PROFILE_ARN="arn:aws:eks:eu-west-1:333320350721:fargateprofile/agentic-research-eks/default/f8ce4135-2240-92b9-d3b1-06bdf8a52656"

MANIFEST_PATH="${1:-$DEFAULT_MANIFEST_PATH}"
RENDERED_MANIFEST_PATH="${MANIFEST_PATH}"

cleanup() {
  if [[ "${RENDERED_MANIFEST_PATH}" != "${MANIFEST_PATH}" && -f "${RENDERED_MANIFEST_PATH}" ]]; then
    rm -f "${RENDERED_MANIFEST_PATH}"
  fi
}
trap cleanup EXIT

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "Manifest file not found: ${MANIFEST_PATH}"
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI is required."
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required."
  exit 1
fi

CURRENT_AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text 2>/dev/null || true)"
if [[ "${CURRENT_AWS_ACCOUNT_ID}" != "${EXPECTED_AWS_ACCOUNT_ID}" ]]; then
  echo "AWS account mismatch: expected ${EXPECTED_AWS_ACCOUNT_ID}, got ${CURRENT_AWS_ACCOUNT_ID:-unknown}."
  echo "Use the correct AWS profile/role before running this script."
  exit 1
fi

read -r -p "AWS region [${DEFAULT_REGION}]: " AWS_REGION
AWS_REGION="${AWS_REGION:-$DEFAULT_REGION}"

read -r -p "EKS cluster name [${DEFAULT_CLUSTER_NAME}]: " EKS_CLUSTER_NAME
EKS_CLUSTER_NAME="${EKS_CLUSTER_NAME:-$DEFAULT_CLUSTER_NAME}"

if grep -q "fs-REPLACE_ME" "${MANIFEST_PATH}"; then
  read -r -p "EFS File System ID (format fs-xxxxxxxx, required for Fargate persistent volume) [${EFS_FILE_SYSTEM_ID}]: " INPUT_EFS_FILE_SYSTEM_ID
  EFS_ID_TO_USE="${INPUT_EFS_FILE_SYSTEM_ID:-$EFS_FILE_SYSTEM_ID}"
  if [[ -z "${EFS_ID_TO_USE}" || ! "${EFS_ID_TO_USE}" =~ ^fs-[a-z0-9]+$ ]]; then
    echo "Invalid EFS File System ID. Expected format: fs-xxxxxxxx"
    exit 1
  fi

  RENDERED_MANIFEST_PATH="$(mktemp)"
  sed "s/fs-REPLACE_ME/${EFS_ID_TO_USE}/g" "${MANIFEST_PATH}" > "${RENDERED_MANIFEST_PATH}"
  echo "Using rendered manifest with EFS ID: ${RENDERED_MANIFEST_PATH}"
fi

echo "Context:"
echo "- ECR repository URL: ${ECR_REPOSITORY_URL}"
echo "- EFS file system ID: ${EFS_FILE_SYSTEM_ID}"
echo "- EFS security group ID: ${EFS_SECURITY_GROUP_ID}"
echo "- Expected EKS endpoint: ${EXPECTED_EKS_ENDPOINT}"
echo "- Cluster security group: ${CLUSTER_SECURITY_GROUP_ID}"
echo "- VPC ID: ${VPC_ID}"
echo "- Fargate profile ARN: ${FARGATE_PROFILE_ARN}"

echo "Updating kubeconfig for cluster ${EKS_CLUSTER_NAME} in ${AWS_REGION}..."
aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}" --region "${AWS_REGION}"

echo "Applying manifest ${RENDERED_MANIFEST_PATH}..."
kubectl apply -f "${RENDERED_MANIFEST_PATH}"

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/web-alb-test -n default --timeout=300s

echo "Ingress status:"
kubectl get ingress web-alb-test-ingress -n default

echo "Done."

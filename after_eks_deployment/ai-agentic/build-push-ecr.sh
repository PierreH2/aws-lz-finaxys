#!/usr/bin/env bash
set -euo pipefail

# Navigate to project root
cd "$(dirname "$0")/.."

ECR_REGISTRY="333320350721.dkr.ecr.eu-west-1.amazonaws.com"
ECR_REPO="agentic-research"
TAG="${1:-latest}"
REGION="eu-west-1"

# ECR login
aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

# Build & push agentic-research
docker build -t "${ECR_REGISTRY}/${ECR_REPO}:agentic-research-${TAG}" \
  -f docker/Dockerfile.agentic-research .

docker push "${ECR_REGISTRY}/${ECR_REPO}:agentic-research-${TAG}"

# Build & push dataprep
docker build -t "${ECR_REGISTRY}/${ECR_REPO}:dataprep-${TAG}" \
  -f docker/Dockerfile.dataprep .

docker push "${ECR_REGISTRY}/${ECR_REPO}:dataprep-${TAG}"

echo "Done. Images pushed:"
echo "  ${ECR_REGISTRY}/${ECR_REPO}:agentic-research-${TAG}"
echo "  ${ECR_REGISTRY}/${ECR_REPO}:dataprep-${TAG}"

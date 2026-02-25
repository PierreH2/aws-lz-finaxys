#!/usr/bin/env bash

set -euo pipefail

DEFAULT_DOCKERHUB_IMAGE="nginx:1.27-alpine"
DEFAULT_TARGET_TAG="fargate-alb-test"
DEFAULT_ECR_REPOSITORY_URL="333320350721.dkr.ecr.eu-west-1.amazonaws.com/agentic-research"

read -r -p "ECR repository URL [${DEFAULT_ECR_REPOSITORY_URL}]: " ECR_REPOSITORY_URL
ECR_REPOSITORY_URL="${ECR_REPOSITORY_URL:-$DEFAULT_ECR_REPOSITORY_URL}"

if [[ -z "${ECR_REPOSITORY_URL}" ]]; then
	echo "ECR repository URL is required."
	exit 1
fi

read -r -p "Docker Hub image [${DEFAULT_DOCKERHUB_IMAGE}]: " DOCKERHUB_IMAGE
DOCKERHUB_IMAGE="${DOCKERHUB_IMAGE:-$DEFAULT_DOCKERHUB_IMAGE}"

read -r -p "Target image tag in ECR [${DEFAULT_TARGET_TAG}]: " TARGET_TAG
TARGET_TAG="${TARGET_TAG:-$DEFAULT_TARGET_TAG}"

if [[ ! "${ECR_REPOSITORY_URL}" =~ ^[0-9]{12}\.dkr\.ecr\.([a-z0-9-]+)\.amazonaws\.com/.+$ ]]; then
	echo "Invalid ECR repository URL format."
	exit 1
fi

AWS_REGION="${BASH_REMATCH[1]}"
ECR_IMAGE_URI="${ECR_REPOSITORY_URL}:${TARGET_TAG}"

echo "Logging in to ECR in region ${AWS_REGION}..."
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REPOSITORY_URL%%/*}"

echo "Pulling image ${DOCKERHUB_IMAGE} from Docker Hub..."
docker pull "${DOCKERHUB_IMAGE}"

echo "Tagging image as ${ECR_IMAGE_URI}..."
docker tag "${DOCKERHUB_IMAGE}" "${ECR_IMAGE_URI}"

echo "Pushing ${ECR_IMAGE_URI} to ECR..."
docker push "${ECR_IMAGE_URI}"

echo
echo "Image pushed successfully."
echo "Use this image in Kubernetes manifest: ${ECR_IMAGE_URI}"

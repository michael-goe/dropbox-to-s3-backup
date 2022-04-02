#!/bin/bash

IMAGE_NAME="s3-to-dropbox"
IMAGE_VERSION="latest"

ECR_REPO_NAME=$(terraform output -raw -state=../terraform/terraform.tfstate ecr_repo_name)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
AWS_REGION=$(aws configure get region)

ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

aws ecr get-login-password | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker buildx build --platform=linux/amd64 -t ${IMAGE_NAME} .
docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${ECR_REPO}:${IMAGE_VERSION}
docker push ${ECR_REPO}:${IMAGE_VERSION}

echo "ECR_REPO: $ECR_REPO"
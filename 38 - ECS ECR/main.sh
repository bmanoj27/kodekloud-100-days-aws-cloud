#!/bin/bash

read -p "Enter ECR Name: " ECR_NAME
read -p "Enter ECS Cluster Name: " ECS_CLUSTER_NAME

DOCKERDIR="/root/pyapp/"
PWDDIR=$(pwd)

cd ${DOCKERDIR}
docker build -t ${ECR_NAME}:latest .

cd ${PWDDIR}
terraform init
terraform apply -var "ecr_name=${ECR_NAME}" -var "ecscluster=${ECS_CLUSTER_NAME}" -auto-approve

ECR_REPO_URL=$(terraform output -raw ecr_repository_url)

echo "Using ECR repo: $ECR_REPO_URL"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO_URL

docker tag "${ECR_NAME}:latest" "$ECR_REPO_URL:latest"
docker push "$ECR_REPO_URL:latest"

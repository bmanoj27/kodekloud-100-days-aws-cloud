#!/bin/bash

cd /root/pyapp/

docker build -t devops-ecr:latest .

terraform init
terraform apply -auto-approve

ECR_REPO_URL=$(terraform output -raw ecr_repository_url)

echo "Using ECR repo: $ECR_REPO_URL"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPO_URL

docker tag "devops-ecr:latest" "$ECR_REPO_URL:latest"

docker push "$ECR_REPO_URL:latest"


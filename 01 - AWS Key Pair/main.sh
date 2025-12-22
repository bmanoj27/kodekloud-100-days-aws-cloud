#!/bin/bash

#Assuming we don't have an existing key pair
#Or we could use an if condition to check if the file exists
#This keeps the private key out of Terraform state and plan

if [-f ~/.ssh/id_rsa ]; then
  echo "SSH key pair already exists. Skipping generation."
  terraform init
  terraform apply -var="keypair_name=$(cat ~/.ssh/id_rsa.pub)" -auto-approve
  exit 0
else
  ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa

  terraform init
  terraform apply -var="keypair_name=$(cat ~/.ssh/id_rsa.pub)" -auto-approve
  exit 0
fi
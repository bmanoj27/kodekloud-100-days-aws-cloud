#!/bin/bash

inst_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-priv-ec2"  --query "Reservations[].Instances[].InstanceId" --output text)
priv_sg_id=$(aws ec2 describe-instances --instance-ids ${inst_id} --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

export TF_VAR_priv_sg_id=${priv_sg_id}

terraform init
terraform plan
terraform apply -auto-approve

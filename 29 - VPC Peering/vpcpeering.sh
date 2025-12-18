#!/bin/bash


vpc_public_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=nautilus-public-ec2"  --query "Reservations[].Instances[].VpcId" --output text)

route_table_public=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=${vpc_public_id}" "Name=association.main,Values=true" --query 'RouteTables[].RouteTableId' --output text)

export TF_VAR_public_vpc_id="${vpc_public_id}"
export TF_VAR_public_rt_id="${route_table_public}"

vpc_private_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=nautilus-private-ec2"  --query "Reservations[].Instances[].VpcId" --output text)

route_table_private=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=${vpc_private_id}" "Name=association.main,Values=true" --query 'RouteTables[].RouteTableId' --output text)

#export TF_VAR_private_vpc_id="${vpc_private_id}"
export TF_VAR_private_rt_id="${route_table_private}"

private_sg=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=nautilus-private-ec2"  --query "Reservations[].Instances[].SecurityGroups[].GroupId" --output text)

export TF_VAR_private_sg_id="${private_sg}"

public_sg=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=nautilus-public-ec2"  --query "Reservations[].Instances[].SecurityGroups[].GroupId" --output text)

export TF_VAR_public_sg_id="${public_sg}"


terraform init
terraform plan
terraform apply -auto-approve
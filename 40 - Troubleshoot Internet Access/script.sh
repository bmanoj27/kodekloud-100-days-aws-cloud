#!/bin/bash

#In this task the IGW is not attached to the desired VPC, so we will attach it and verify internet access.

read -p "Enter the VPC/EC2 Name (Example: devops, nautilis, xfusion) " DEVOPS_NAME

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${DEVOPS_NAME}-vpc" --query "Vpcs[].VpcId" --output text)
IGW_ID=$(aws ec2 describe-internet-gateways   --query 'InternetGateways[?length(Attachments)==`0`].InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --internet-gateway-id ${IGW_ID} --vpc-id ${VPC_ID}

PUBLIC_IP=$(aws ec2 describe-instances --filter "Name=tag:Name, Values=${DEVOPS_NAME}-ec2" --query "Reservations[].Instances[].PublicIpAddress" --output text)

curl http://${PUBLIC_IP}:80

#!/bin/bash

if ! command -v aws >/dev/null 2>&1
then
    echo "AWS CLI could not be found. Please install it to run this script."
    echo "https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1
then
    echo "AWS CLI is not configured. Please configure it to run this script."
    echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html"
    exit 1
fi

# This script creates an EC2 instance and associates an Elastic IP with it.

# Variables
echo "Creating SSH Key Pair..."
read -p "Enter a name for the SSH key pair: " key_name

aws ec2 create-key-pair --key-name ${key_name} --query 'KeyMaterial' --output text > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

#optional: generate public key from private key
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

echo "Finding latest Ubuntu AMI"
ami_id=$(aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
            "Name=state,Values=available" \
  --query 'Images | sort_by(@,&CreationDate)[-1].ImageId' \
  --output text
)

read -p "Enter a name for EC2 Instance: " instance_name
echo "Launching EC2 Instance..."
ec2id=$(aws ec2 run-instances --image-id ${ami_id} \
    --count 1 \
    --instance-type t2.micro \
    --key-name ${key_name} \
    --query 'Instances[0].InstanceId' \
    --output text)

sleep 15

echo "Allocating Elastic IP..."
eip_allocation_id=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)

echo "Associating Elastic IP with EC2 Instance..."
aws ec2 associate-address --instance-id ${ec2id} --allocation-id ${eip_allocation_id}

aws ec2 create-tags \
  --resources "${eip_allocation_id}" \
  --tags Key=Name,Value=${instance_name}-eip

aws ec2 create-tags \
  --resources "${ec2id}" \
  --tags Key=Name,Value=${instance_name}

aws ec2 describe-addresses \
  --allocation-ids "${eip_allocation_id}" \
  --query 'Addresses[0].PublicIp' \
  --output text

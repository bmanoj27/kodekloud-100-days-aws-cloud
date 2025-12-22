#!/bin/bash

terraform init
terraform apply -auto-approve

if [ -f ~/.ssh/id_rsa ]; then
    echo "SSH key already exists"
else
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q -N ""
fi

echo "Add the public key to your EC2 instance before running terraform apply"
echo "Permit Root Login in the EC2 instance /etc/ssh/sshd_config file"
sleep 30

while true; do
    read -p "Have you added the public key to the EC2 instance? (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please add the public key to the EC2 instance before proceeding.";;
        * ) echo "Please answer yes or no.";;
    esac
done

ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa root@$(terraform output -raw ec2_public_ip) "aws s3 ls s3://$(terraform output -raw s3_bucket_name)/"
#!/bin/bash

read -p "Enter EC2 Instance Name: " ec2inst

inst_id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${ec2inst}"  --query "Reservations[].Instances[].InstanceId" --output text)
inst_pub_ip=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${ec2inst}"  --query "Reservations[].Instances[].PublicIpAddress" --output text)
priv_sg_id=$(aws ec2 describe-instances --instance-ids ${inst_id} --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

export TF_VAR_priv_sg_id=${priv_sg_id}

terraform init
terraform apply -auto-approve

rdshost=$(aws rds describe-db-instances --query "DBInstances[].Endpoint.Address" --output text)

if [ -f ~/.ssh/id_rsa ]; then
    echo "SSH Key already exists"
else
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

echo "RDS Instance has been created now you have to copy the id_rsa.pub key to the EC2 Instance using AWS Web Console..."
echo "Copy the key and permit root user to login..."

read -p "Continue? yes or no: " qstn

if [[ ${qstn} == "yes" ]]; then
    ssh -i ~/.ssh/id_rsa ubuntu@"${inst_pub_ip}" << EOF
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    exit
EOF

else
    echo "add they key and rerun"
fi
cp /root/index.php /root/index.php2

sed -i 's/<dbname>/datacenter_db/g' /root/index.php
sed -i 's/<dbuser>/datacenter_admin/g' /root/index.php
sed -i 's/<dbpass>/nimda_sulituan/g' /root/index.php
sed -i 's/<dbhost>/${rdshost}:3306/g' /root/index.php

scp -i ~/.ssh/id_rsa /root/index.php root@${inst_pub_ip}:/var/www/html/index.php

curl http://${inst_pub_ip}:80

exit 0

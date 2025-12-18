#TASK
#The Nautilus DevOps team needs to set up a new EC2 instance that can be accessed securely from their landing host (aws-client). 
#The instance should be of type t2.micro and named nautilus-ec2. A new SSH key should be created on the aws-client host
#under the/root/.ssh/ folder, if it doesn't already exist. 
#This key should then be added to the root user's authorised keys on the EC2 instance, 
#allowing passwordless SSH access from the aws-client host.

resource "tls_private_key" "id_rsa" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "devops_key_private" {
  content  = tls_private_key.id_rsa.private_key_pem
  filename = "/root/.ssh/id_rsa"
  file_permission = "0600"
  
}

resource "local_file" "devops_key_public" {
  content  = tls_private_key.id_rsa.public_key_openssh
  filename = "/root/.ssh/id_rsa.pub"
  file_permission = "0644"
}

resource "aws_key_pair" "devops-ec2" {
  key_name = "devops-ec2"
  #depends_on = [tls_private_key.devops_key]  #not needed as already next line references it so it will wait.
  public_key = tls_private_key.id_rsa.public_key_openssh
}

resource "aws_security_group" "devops-sg" {
  name        = "devops-sg"
  description = "Allow SSH from aws-client"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "devops-sg"
  }
}

resource "aws_instance" "devops-ec2" {
    ami = "ami-068c0051b15cdb816"
    associate_public_ip_address = true
    instance_type = var.instance_type
    vpc_security_group_ids = [ aws_security_group.devops-sg.id ]
    key_name = aws_key_pair.devops-ec2.key_name

    user_data = <<-EOF
                #!/bin/bash
                mkdir -p /root/.ssh
                echo "${tls_private_key.id_rsa.public_key_openssh}" > /root/.ssh/authorized_keys
                chmod 600 /root/.ssh/authorized_keys
                sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
                EOF
    tags = {
      name = var.instance_name
    }
}


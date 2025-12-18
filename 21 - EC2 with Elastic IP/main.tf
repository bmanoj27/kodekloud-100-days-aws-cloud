terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable "instance_name" {
  description = "Name of the required Instance"
  type = string
  default = "xfusion-ec2"
}

variable "instance_type" {
  description = "Type of the required Instance"
  default = "t2.micro"
  type = string
}

variable "eip_name" {
  description = "Name of the Elastic IP"
  type = string
  default = "xfusion-eip"
}

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
  public_key = tls_private_key.id_rsa.public_key_openssh
}

#MAIN

resource "aws_instance" "devops-ec2" {
    ami = "ami-068c0051b15cdb816"
    associate_public_ip_address = true
    instance_type = var.instance_type
   # vpc_security_group_ids = [ aws_security_group.devops-sg.id ]
    key_name = aws_key_pair.devops-ec2.key_name

    tags = {
      Name = var.instance_name
    }
}

resource "aws_eip" "devops-eip" {
  instance = aws_instance.devops-ec2.id
  domain   = "vpc"

  tags = {
    name = var.eip_name
  }
}

output "ElasticIP" {
    description = "Public IP of newly created instance"
    value = aws_eip.devops-eip.public_ip
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "instance_name" {
  description = "Name of the required Instance"
  type = string
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_vpc" "default" {
  default = true
}

#SSHKEY
resource "tls_private_key" "id_rsa" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "devops_key_private" {
  content  = tls_private_key.id_rsa.private_key_pem
  filename = "/root/.ssh/id_rsa"
  file_permission = "0600"
  
}

resource "aws_key_pair" "devops-ec2" {
  key_name = "devops-ec2"
  public_key = tls_private_key.id_rsa.public_key_openssh
}
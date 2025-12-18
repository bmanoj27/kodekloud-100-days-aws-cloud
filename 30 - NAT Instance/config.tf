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

data "aws_vpc" "private_vpc" {
    filter {
      name   = "tag:Name"
      values = ["devops-priv-vpc"]
    }
}

data "aws_subnet" "private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["devops-priv-subnet"]
  }
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

resource "aws_key_pair" "devops-ec2" {
  key_name = "devops-ec2"
  public_key = tls_private_key.id_rsa.public_key_openssh
}

data "aws_route_table" "private_route_table" {
  subnet_id = data.aws_subnet.private_subnet.id
}
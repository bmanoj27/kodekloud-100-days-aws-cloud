terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name = "default"
  vpc_id = data.aws_vpc.default.id
}

#This type of key creation will expose the private key in the Terraform state file.
#just for reference.
resource "tls_private_key" "id_rsa" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "devops_key_private" {
  content  = tls_private_key.id_rsa.private_key_pem
  filename = "/root/.ssh/id_rsa"
  file_permission = "0600"
  
}

resource "aws_key_pair" "devops-kp" {
  key_name = "devops-kp"
  public_key = tls_private_key.id_rsa.public_key_openssh
}

resource "aws_instance" "devops-ec2" {
    ami = data.aws_ami.amzn-linux-2023-ami.id
    instance_type = "t2.micro"
    key_name = aws_key_pair.devops-kp.key_name
    vpc_security_group_ids = [data.aws_security_group.default.id]

    tags = {
      Name = "devops-ec2"
    }
}
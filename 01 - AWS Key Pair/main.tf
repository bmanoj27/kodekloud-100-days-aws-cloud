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

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for EC2"
}

variable "keypair_name" {
  type = string
  description = "Name for the keypair"
  default = "devops-ec2"
}

resource "aws_key_pair" "main" {
  key_name   = var.keypair_name
  public_key = var.ssh_public_key
}

output "keypair" {
  description = "ID of the created key pair."
  value = aws_key_pair.main.id
}
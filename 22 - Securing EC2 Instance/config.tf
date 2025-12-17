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

data "aws_vpc" "default" {
  default = true
}

variable "instance_name" {
  description = "Name of the required Instance"
}

variable "instance_type" {
  description = "Type of the required Instance"
  default = "t2.micro"
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.devops-ec2.public_ip
}
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

variable "sg_name" {
  type = string
  default = "devops-sg"
}

data "aws_vpc" "default_vpc" {
    default = true
}

resource "aws_security_group" "devops_sg" {
  name = var.sg_name
  description = "Security group for Nautilus App Servers"
  vpc_id = data.aws_vpc.default_vpc.id

  tags = {
    Name = var.sg_name
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress = {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
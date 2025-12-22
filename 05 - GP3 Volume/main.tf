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

resource "aws_ebs_volume" "gp3_volume" {
  availability_zone = "us-east-1a"
  size              = 2
  type              = "gp3"

  tags = {
    Name = "devops-volume"
  }
}
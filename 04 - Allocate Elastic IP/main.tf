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

#EIP may require IGW to exist prior to association.

resource "aws_eip" "devops_eip" {
  domain = "vpc"

    tags = {
        Name = "devops_eip"
    }
}

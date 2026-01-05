terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "eks_role" {
  default = "eksClusterRole"
  type = string
}

variable "eks_name" {
  default = "devops-eks"
  type = string
}

#########

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}
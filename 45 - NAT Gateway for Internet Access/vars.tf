terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "priv_vpc" {
  filter {
    name   = "tag:Name"
    values = ["devops-priv-vpc"]
  }
}

data "aws_instance" "devops_ec2" {
  filter {
    name   = "tag:Name"
    values = ["devops-priv-ec2"]
  }
}

data "aws_subnet" "priv_subnet" {
  filter {
    name   = "tag:Name"
    values = ["devops-priv-subnet"]
  }
}


data "aws_route_table" "priv_rt" {
  vpc_id = data.aws_vpc.priv_vpc.id


  filter {
    name   = "association.main"
    values = ["true"]
  }
}
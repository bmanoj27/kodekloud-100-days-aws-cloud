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


data "aws_vpc" "public_vpc" {
    default = true
}

data "aws_vpc" "private_vpc" {
    filter {
        name   = "tag:Name"
        values = ["nautilus-private-vpc"]
    }
}

#data "aws_subnet" "public_subnet" {
#    id = data.aws_instance.public_instance.subnet_id
#}

#data "aws_subnet" "private_subnet" {
#    filter {
#      name = "tag:Name"
#      values = ["nautilus-private-subnet"]
#    }
#}

#data "aws_instance" "public_instance" {
#    filter {
#    name   = "tag:Name"
#    values = ["nautilus-public-ec2"]
#  }
#}

#data "aws_instance" "private_instance" {
#    filter {
#    name   = "tag:Name"
#    values = ["nautilus-private-ec2"]
#  }
#}
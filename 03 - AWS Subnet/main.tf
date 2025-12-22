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

data "aws_vpc" "default" {
  default = true
}

resource "aws_subnet" "devops_subnet" {
    vpc_id = data.aws_vpc.default.id
    cidr_block = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 0)
    
    tags = {
      Name = "devops_subnet"
    }
}

#An example to create two subnets...

#resource "aws_subnet" "devops_subnet" {
#  count                   = 2
#  vpc_id                  = data.aws_vpc.default.id
#  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, count.index)
#  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
#  map_public_ip_on_launch = true
#
#  tags = {
#    Name = "devops-subnet-${count.index + 1}"
#  }

#https://developer.hashicorp.com/terraform/language/functions/cidrsubnet  
#
#}
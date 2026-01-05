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

variable "instance_name" {
  type = string
  default = "datacenter"
}

variable "auto_scaling_name" {
  type = string
  default = "datacenter-asg"
}

variable "alb_name" {
  type = string
  default = "datacenter-alb"
}

variable "target_group" {
  type = string
  default = "datacenter-tg"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "lb_dns" {
  value = aws_lb.ec2_lb.dns_name
}
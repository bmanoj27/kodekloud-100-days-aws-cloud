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

variable "instance_name" {
  description = "Name of the required Instance"
  type = string
}

variable "snstopic" {
  description = "Name of the SNS Topic"
  default = "xfusion-sns-topic"
}

variable "alarmname" {
  description = "Name of the CloudWatch Alarm"
  default = "xfusion-alarm"
}

data "aws_sns_topic" "topic" {
  name = var.snstopic
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
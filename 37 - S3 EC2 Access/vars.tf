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

#Bucket Name
variable "bucketname" {
  type = string
  default = "nautilus-s3-27441"
}

variable "ec2name" {
  type = string
  default = "nautilus-ec2"
}

variable "rolename" {
  type = string
  default = "nautilus-role"
}

variable "policyname" {
  type = string
  default = "nautilus-policy"
}

#Data
data "aws_instance" "devops-ec2" {
  filter {
    name   = "tag:Name"
    values = [var.ec2name]
  }
}


output "ec2_public_ip" {
  value = data.aws_instance.devops-ec2.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.devops_bucket.bucket
}
#Create a New Private S3 Bucket: Name the bucket datacenter-sync-4819.
#Data Migration: Migrate the entire data from the existing datacenter-s3-31956 bucket 
#to the new datacenter-sync-4819 bucket.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

variable "source_bucket" {
  description = "Name of the source S3 bucket"
  type        = string
}

variable "dest_bucket" {
  description = "Name of the destination/new bucket"
  type       = string 
}

data "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket
}

resource "aws_s3_bucket" "dest_bucket" {
  bucket = var.dest_bucket

  tags = {
    name        = var.dest_bucket
  }
}

resource "null_resource" "sync_data" {
    depends_on = [ aws_s3_bucket.dest_bucket ]

    provisioner "local-exec" {

    command = "aws s3 sync s3://${data.aws_s3_bucket.source_bucket.bucket} s3://${aws_s3_bucket.dest_bucket.bucket}"
    }
}


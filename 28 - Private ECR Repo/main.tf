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

variable "ecr_name" {
  description = "Name of the ECR"
  type = string
  default = "devops-ecr"
}

resource "aws_ecr_repository" "devops-ecr" {
  name = var.ecr_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }  
  
  tags = {
    Name = var.ecr_name
  }
}

output "ecr_repository_url" {
  description = "URL of the ECR Repository"
  value       = aws_ecr_repository.devops-ecr.repository_url
}



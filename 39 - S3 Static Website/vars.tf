terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.27.0"
    }
  }

  backend "s3" {
    bucket = "nautilus-web-16627"  #Variables wont work here.
    key    = "terraform.tfstate"
    region = "us-east-1"
  }   # have to reinitialize after adding backend

}

provider "aws" {
  region = "us-east-1"
}


variable "bucketname" {
  type = string
  default = "nautilus-web-16627"
}

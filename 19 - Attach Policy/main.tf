#An IAM user named iamuser_mariyam and a policy named iampolicy_mariyam already exist. 
#Attach the IAM policy iampolicy_mariyam to the IAM user iamuser_mariyam.

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

variable "policy_name" {
  description = "Name of the policy"
  type = string
}

variable "aws_iam_user" {
  description = "Name of the IAM User"
  type = string
}

data "aws_iam_policy" "policy" {
  name = var.policy_name
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = var.aws_iam_user
  policy_arn = data.aws_iam_policy.policy.arn
}
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

variable "lambda_function"  {
  default = "xfusion-lambda"
  type = string
}

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "exec_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Lambda function code
#or directly reference the zip 
data "archive_file" "python_zip" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename = data.archive_file.python_zip.output_path
  function_name = var.lambda_function
  role = aws_iam_role.exec_role.arn
  handler       = "lambda.lambda_handler"
  runtime = "python3.14"
  tags = {
    Name = var.lambda_function
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change if needed
}

# Variables for easy customization
variable "lambda_code_path" {
  description = "Path to lambda-function.py on local machine"
  default     = "/root/lambda-function.py"  # Update this path
}

variable "dynamodb_table_name" {
  default = "xfusion-S3CopyLogs"
}

variable "public_bucket_name" {
  default = "xfusion-public-20002"
}

variable "private_bucket_name" {
  default = "xfusion-private-21190"
}

# ========================================
# PUBLIC S3 BUCKET (allows public uploads)
# ========================================
resource "aws_s3_bucket" "public" {
  bucket = var.public_bucket_name
}

# Enable public access (for uploads)
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Public bucket policy - allows public PUT (uploads)
resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicUpload"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.public.arn}/*"
      }
    ]
  })
}

# ========================================
# PRIVATE S3 BUCKET (secure storage)
# ========================================
resource "aws_s3_bucket" "private" {
  bucket = var.private_bucket_name
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.private.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ========================================
# DYNAMODB TABLE FOR LOGS
# ========================================
resource "aws_dynamodb_table" "s3_copy_logs" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LogID"

  attribute {
    name = "LogID"
    type = "S"
  }

  tags = {
    Name = "S3CopyLogs"
  }
}

# ========================================
# IAM ROLE AND POLICY FOR LAMBDA
# ========================================
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Your exact least-privilege policy
resource "aws_iam_role_policy" "lambda_s3_dynamodb_policy" {
  name = "S3DynamoDBCopyAccess"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBuckets"
        Effect = "Allow"
        Action = "s3:ListBucket"
        Resource = [
          aws_s3_bucket.public.arn,
          aws_s3_bucket.private.arn
        ]
      },
      {
        Sid    = "GetObjectPublic"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.public.arn}/*"
      },
      {
        Sid    = "PutObjectPrivate"
        Effect = "Allow"
        Action = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.private.arn}/*"
      },
      {
        Sid    = "DynamoDBPutItem"
        Effect = "Allow"
        Action = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.s3_copy_logs.arn
      }
    ]
  })
}

# Basic Lambda execution role (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ========================================
# LAMBDA FUNCTION
# ========================================
# ZIP the Python file (assumes it's local)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_code_path
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "copy_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "xfusion-copyfunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"  # Update if different
  runtime          = "python3.9"  # Update to match your py version
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.s3_copy_logs.name
      PRIVATE_BUCKET = aws_s3_bucket.private.bucket
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

# Lambda permission to be invoked by S3
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3PublicBucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.copy_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.public.arn
}

# ========================================
# S3 EVENT TRIGGER
# ========================================
resource "aws_s3_bucket_notification" "public_bucket_notification" {
  bucket = aws_s3_bucket.public.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.copy_function.arn
    events              = ["s3:ObjectCreated:*"]
    # include_existing_object_patterns = ["*"]  # Uncomment if needed
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

# ========================================
# OUTPUTS
# ========================================
output "public_bucket_name" {
  value = aws_s3_bucket.public.bucket
}

output "private_bucket_name" {
  value = aws_s3_bucket.private.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.s3_copy_logs.name
}

output "lambda_function_name" {
  value = aws_lambda_function.copy_function.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.copy_function.arn
}

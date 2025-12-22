resource "aws_s3_bucket" "devops_bucket" {
  bucket = var.bucketname

  tags = {
    Name        = var.bucketname
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.devops_bucket.id
  key    = "index.html"
  source = "/root/index.html"

  #The etag = filemd5("path/to/file") line sets an optional ETag attribute for the S3 object,
  #using Terraform's filemd5() function to compute an MD5 hash of the specified source file's content
  
  #Purpose
  #Terraform compares this ETag value against the current state during plan and apply.
  #If the hash changes (due to file modifications), it triggers an update to re-upload the object, 
  #ensuring content stays in sync without manual intervention

  etag = filemd5("/root/index.html")
  content_type = "text/html"  # Forces browser to render as HTML, didnt work without this.
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.devops_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "devops_static_website" {
  bucket = aws_s3_bucket.devops_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_web_policy" {
  bucket = aws_s3_bucket.devops_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.devops_bucket.arn}/*"
      }
    ]
  })
}

output "public_endpoint" {
  value = aws_s3_bucket_website_configuration.devops_static_website.website_endpoint
}
resource "aws_s3_bucket" "devops_bucket" {
  bucket = var.bucketname

  tags = {
    Name        = var.bucketname
  }
}

resource "aws_security_group_rule" "ssh_access" {

  for_each = data.aws_instance.devops-ec2.vpc_security_group_ids

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = each.value
}

resource "aws_iam_policy" "s3access" {
  name = var.policyname
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
        {
        "Sid": "AllowListBucket",
        "Effect": "Allow",
        "Action": "s3:ListBucket",
        "Resource": "arn:aws:s3:::${var.bucketname}"
        },
        {
        "Sid": "AllowObjectActions",
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::${var.bucketname}/*"
        }

	]
})

  tags = {
    Name = var.policyname
  }
}

resource "aws_iam_role" "s3role" {
  name = var.rolename

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = var.rolename
  }
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.s3role.name
  policy_arn = aws_iam_policy.s3access.arn
}
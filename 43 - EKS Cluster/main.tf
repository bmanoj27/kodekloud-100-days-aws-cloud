resource "aws_iam_role" "eks_role" {
  name = var.eks_role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

    tags = {
        Name = var.eks_role
    }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_eks_cluster" "devops-eks" {
    name = var.eks_name
    role_arn = aws_iam_role.eks_role.arn
    version = "1.30"

    vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false

    subnet_ids = data.aws_subnets.default.ids
  }

    tags = {
        Name = var.eks_name
    }

    depends_on = [ aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy ]
}
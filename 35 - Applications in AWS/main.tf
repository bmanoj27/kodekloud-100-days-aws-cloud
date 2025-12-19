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

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Security Group for RDS Instance"
  vpc_id      = data.aws_subnet.subnet_ec2.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.priv_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_db_instance" "rds_instance" {
    db_name = var.db_name
    instance_class = "db.t3.micro"
    engine = "mysql"
    engine_version = "8.4.5"
    allocated_storage = 5
    username = var.db_user
    password = var.db_pass
    identifier = var.rds_instance
    storage_type = "gp2"
    #db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]

    tags = {
      Name = var.rds_instance
    }
}

#Modify EC2 Security Group
resource "aws_security_group_rule" "ec2_sg_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.priv_sg_id
}

resource "aws_security_group_rule" "ec2_ssh_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.priv_sg_id
}

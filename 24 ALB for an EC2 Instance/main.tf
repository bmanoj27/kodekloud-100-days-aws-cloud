#Set up an Application Load Balancer named nautilus-alb.
#Create a target group named nautilus-tg.
#Create a security group named nautilus-sg to open port 80 for the public.
#Attach this security group to the ALB.
#The ALB should route traffic on port 80 to port 80 of the nautilus-ec2 instance.
#Make appropriate changes in the default security group attached to the EC2 instance if necessary.

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

data "aws_instance" "nautilus-ec2" {
  filter {
    name   = "tag:Name"
    values = ["nautilus-ec2"]
  }
}

data "aws_subnet" "instance_subnet" {
  id = data.aws_instance.nautilus-ec2.subnet_id
}

data "aws_subnets" "instance_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.instance_subnet.vpc_id]
  }
}

data "aws_security_group" "default_vpc_sg" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  vpc_id = data.aws_subnet.instance_subnet.vpc_id
}

resource "aws_security_group" "nautilus-sg" {
  name        = "nautilus-sg"
  description = "Allow HTTP Traffic"
  vpc_id      = data.aws_subnet.instance_subnet.vpc_id

  tags = {
    name = "nautilus-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "alb_to_instance_80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nautilus-sg.id
  security_group_id        = data.aws_security_group.default_vpc_sg.id
}


resource "aws_lb_target_group" "nautilus-tg" {
  name     = "nautilus-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_subnet.instance_subnet.vpc_id
}

resource "aws_lb_target_group_attachment" "nautilus-tg" {
  target_group_arn = aws_lb_target_group.nautilus-tg.arn
  target_id        = data.aws_instance.nautilus-ec2.id
  port             = 80
}

resource "aws_lb" "nautilus-alb" {
  name               = "nautilus-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nautilus-sg.id]
  subnets            = data.aws_subnets.instance_vpc_subnets.ids
  enable_deletion_protection = true
}

resource "aws_lb_listener" "nautilus-listener" {
  load_balancer_arn = aws_lb.nautilus-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nautilus-tg.arn
  }

}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.nautilus-alb.dns_name
}
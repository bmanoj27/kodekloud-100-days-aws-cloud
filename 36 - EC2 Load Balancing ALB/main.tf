
#Security Group for EC2 to allow ALP port 80 con.

resource "aws_security_group" "xfusion_sg" {
  name = var.ec2_sg_name
  description = "SG to allow port 80 connection from Load Balancer"
  vpc_id = data.aws_vpc.default_vpc.id

  tags = {
    Name = var.ec2_sg_name
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [data.aws_security_group.default_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devops_ec2" {
  ami = data.aws_ami.ubuntu.id
  security_groups = [aws_security_group.xfusion_sg.name]
  instance_type = "t2.micro"
  key_name = aws_key_pair.devops-ec2.id
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
  
  tags = {
    Name = var.ec2_name
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name = var.tg_name
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id = aws_instance.devops_ec2.id
  port = 80
}

data "aws_subnet" "default_inst_subnet" {
    id = aws_instance.devops_ec2.subnet_id
}

data "aws_subnets" "default_inst_subnets" {
    filter {
      name = "vpc-id"
      values = [data.aws_subnet.default_inst_subnet.vpc_id]
    }
}

resource "aws_lb" "ec2_lb" {
  name = var.alb_name
  internal = false
  load_balancer_type = "application"
  security_groups = [data.aws_security_group.default_sg.id]
  enable_deletion_protection = false
  subnets = data.aws_subnets.default_inst_subnets.ids
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.ec2_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    }

}

resource "aws_security_group_rule" "allow_http" {
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = data.aws_security_group.default_sg.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.ec2_lb.dns_name
}
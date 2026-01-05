resource "aws_security_group" "nginx_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Nginx web server"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = var.instance_name
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "devops-ec2-lt" {
  name = "${var.instance_name}-launch-template"
  image_id = "ami-068c0051b15cdb816"
  region = "us-east-1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.nginx_sg.id ]

  user_data = base64encode(<<-EOF
                              #!/bin/bash
                              yum update -y
                              yum install nginx -y
                              systemctl start nginx
                              systemctl enable nginx
                              EOF
  )
}

resource "aws_lb_target_group" "datacenter_tg" {
  name     = var.target_group
  port     = 80
  protocol = "HTTP"
  vpc_id  = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "ec2_lb" {
  name = var.alb_name
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.nginx_sg.id]
  enable_deletion_protection = false
  subnets = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "ec2_lb_listener" {
  load_balancer_arn = aws_lb.ec2_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.datacenter_tg.arn
  }
}

resource "aws_autoscaling_group" "devops-ec2-asg" {
  name = var.auto_scaling_name
  min_size = 1
  max_size = 2
  desired_capacity = 1
  force_delete = false
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id = aws_launch_template.devops-ec2-lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.datacenter_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-50-target"
  autoscaling_group_name = aws_autoscaling_group.devops-ec2-asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

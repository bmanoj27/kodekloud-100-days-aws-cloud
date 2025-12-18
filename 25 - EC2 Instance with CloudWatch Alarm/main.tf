resource "tls_private_key" "id_rsa" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "devops_key_private" {
  content  = tls_private_key.id_rsa.private_key_pem
  filename = "/root/.ssh/id_rsa"
  file_permission = "0600"
  
}

resource "aws_key_pair" "devops-ec2" {
  key_name = "devops-ec2"
  public_key = tls_private_key.id_rsa.public_key_openssh
}

resource "aws_instance" "devops-ec2" {
    ami = data.aws_ami.ubuntu.id
    associate_public_ip_address = true
    instance_type = "t2.micro"
   # vpc_security_group_ids = [ aws_security_group.devops-sg.id ]
    key_name = aws_key_pair.devops-ec2.key_name

    tags = {
      Name = var.instance_name
    }
}

resource "aws_cloudwatch_metric_alarm" "xfusion-alarm" {
  alarm_name = var.alarmname
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 300
  statistic = "Average"
  threshold = 90
  alarm_description = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.devops-ec2.id
  }

  alarm_actions = [data.aws_sns_topic.topic.arn]
}
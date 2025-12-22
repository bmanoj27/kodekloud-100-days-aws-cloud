variable "ecr_name" {
  type = string
  default = "devops-ecr"
}

variable "ecscluster" {
  type = string
  default = "devops-cluster"
}

variable "taskdefinition" {
  type = string
  default = "devops-taskdefinition"
}

variable "ecssrvie" {
  type = string
  default = "devops-service"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = data.aws_vpc.default.id

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

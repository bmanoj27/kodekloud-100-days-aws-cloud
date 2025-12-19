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

resource "aws_vpc" "rds_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "rds_vpc"
    env = "rds"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.rds_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
    tags = {
    Name = "private_subnet_1"
    env = "rds"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.rds_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"  
  map_public_ip_on_launch = false
    tags = {
    Name = "private_subnet_2"
    env = "rds"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id = aws_vpc.rds_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"  
  map_public_ip_on_launch = false
    tags = {
    Name = "private_subnet_3"
    env = "rds"
  }
}

#Make sure to create this correctly, as the lab iam user doesnt have access to modify/delete subnet_groups as of 19122025
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
}  

resource "aws_security_group" "rds_sg" {
    vpc_id = aws_vpc.rds_vpc.id

    ingress {
        description = "MySQL access"
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]       
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "xfusion-rds-sg"
  }
}

#MAIN

resource "aws_db_instance" "xfusion-rds" {
    db_name = "xfusionrds"
    instance_class = "db.t3.micro"
    engine = "mysql"
    engine_version = "8.4.4"
    allocated_storage = 10
    max_allocated_storage = 50
    username = "rdsuserroot"
    password = "mypa55foobar"   #Pass this using a variable or other way in general use cases.
    identifier = "xfusion-rds"
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]

    tags = {
      Name = "xfusion-rds"
    }
}
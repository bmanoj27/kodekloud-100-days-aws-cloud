resource "aws_vpc" "devops_vpc" {
    cidr_block = "10.130.0.0/16"
    tags = {
        Name = var.vpc_name
    }
}

resource "aws_subnet" "devops_subnet" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = "10.130.1.0/24"
    map_public_ip_on_launch = true

    tags = {
      Name = var.vpc_subnet
    }
}

resource "aws_internet_gateway" "devops_igw" {
    vpc_id = aws_vpc.devops_vpc.id

    tags = {
        Name = "devops-igw"
    }
}

resource "aws_route_table" "devops_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_igw.id
    }

    tags = {
        Name = "devops-route-table"
    }
}

resource "aws_route_table_association" "route_attach" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.devops_route_table.id
}

resource "aws_security_group" "devops_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group SSH Allow"
  vpc_id      = aws_vpc.devops_vpc.id
  
  tags = {
    Name = var.instance_name
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "devops_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.devops-ec2.key_name
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  subnet_id = aws_subnet.devops_subnet.id
  tags = {
    Name = var.instance_name
  }
}
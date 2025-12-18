resource "aws_subnet" "public_subnet" {
  vpc_id     = data.aws_vpc.private_vpc.id
  cidr_block = "10.1.20.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-pub-subnet"
  }
}

resource "aws_internet_gateway" "nat-igw" {
  vpc_id = data.aws_vpc.private_vpc.id

  tags = {
    Name = "nat-inst-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = data.aws_vpc.private_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nat-igw.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = data.aws_vpc.private_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.private_vpc.cidr_block]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  tags ={
    Name = "nat-instance-sg"
  }
}

resource "aws_instance" "nat_instance" {
  ami                         = "ami-0015c0130d6cc5da7"# Amazon Linux 2 NAT Instnace
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.devops-ec2.key_name
  vpc_security_group_ids      = [aws_security_group.nat_sg.id]
  source_dest_check           = false

  tags = {
    Name = "devops-nat-instance"
  }
}

resource "aws_route" "nat_route" {
    route_table_id = data.aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
}

resource "aws_security_group_rule" "allow_from_vpc" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "-1"
  cidr_blocks       = [data.aws_vpc.private_vpc.cidr_block]
  security_group_id = "sg-07536973ee2788de3"
}
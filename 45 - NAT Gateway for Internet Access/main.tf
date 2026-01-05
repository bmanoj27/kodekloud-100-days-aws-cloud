resource "aws_subnet" "devops_subnet" {
  vpc_id                  = data.aws_vpc.priv_vpc.id
  cidr_block              = cidrsubnet(data.aws_vpc.priv_vpc.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  tags = {
    Name = "devops-pub-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = data.aws_vpc.priv_vpc.id

  tags = {
    Name = "devops_igw"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = data.aws_vpc.priv_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "devops-pub-rt"
  }
}

resource "aws_route_table_association" "pub_rt_assoc" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_eip" "lb" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.devops_subnet.id

  tags = {
    Name = "devops-natgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route" "public_access" {
  route_table_id         = data.aws_route_table.priv_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "priv_rt_assoc" {
  subnet_id      = data.aws_subnet.priv_subnet.id
  route_table_id = data.aws_route_table.priv_rt.id
}
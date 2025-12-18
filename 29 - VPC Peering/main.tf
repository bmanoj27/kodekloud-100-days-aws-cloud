resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id   = data.aws_vpc.private_vpc.id
  vpc_id        = data.aws_vpc.public_vpc.id

  tags = {
    Name = "nautilus-vpc-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "peeraccept" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  auto_accept               = true
}

resource "aws_route" "public_route_to_private" {
  route_table_id            = var.public_rt_id
  destination_cidr_block    = data.aws_vpc.private_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  
}

resource "aws_route" "private_route_to_public" {
  route_table_id            = var.private_rt_id
  destination_cidr_block    = data.aws_vpc.public_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
  
}

resource "aws_security_group_rule" "allow_private_to_public" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = var.private_sg_id
  cidr_blocks              = [data.aws_vpc.public_vpc.cidr_block]
  description              = "Allow ICMP from private to public instance"
}

resource "aws_security_group_rule" "allow_ssh_to_public" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = var.public_sg_id
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "Allow SSH"
}

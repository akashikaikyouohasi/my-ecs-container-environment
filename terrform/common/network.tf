# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = local.cidr_block
  enable_dns_support   = true #Interface型VPCエンドポイントのために必要
  enable_dns_hostnames = true #Interface型VPCエンドポイントのために必要

  tags = {
    Name = var.name
  }
}

# Public Subnet
resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.name
  }
}
# private Subnet
resource "aws_subnet" "private_subnets" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.name
  }
}
# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}
# public route table
resource "aws_route_table" "public_route_table" {
  for_each = local.public_route_table

  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = each.value.name
  }
}
# private route table
resource "aws_route_table" "private_route_table" {
  for_each = local.private_route_table

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = each.value.name
  }
}

# 割り当て
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_route_table[each.value.route_table_name].id
}
resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_route_table[each.value.route_table_name].id
}

#########################
# セキュリティグループ
#########################
resource "aws_security_group" "sg" {
  for_each = toset(local.security_group)

  name   = each.key
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "sg_rule" {
  for_each = local.security_group_rule

  type      = "ingress"
  from_port = each.value.port
  to_port   = each.value.port
  protocol  = each.value.protocol

  security_group_id = aws_security_group.sg[each.value.sg].id

  # source_security_group_idとcidr_blocksは排他運用
  source_security_group_id = each.value.source_security_group_id != null ? aws_security_group.sg[each.value.source_security_group_id].id : null
  cidr_blocks              = each.value.cidr_blocks != null ? [each.value.cidr_blocks] : null
}

#########################
# NAT Gateway
#########################
# EIP
resource "aws_eip" "nat_gateway" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "private" {
  for_each = local.nat_gateway

  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnets[each.key].id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "nat_gateway" {
  for_each = local.nat_gateway

  destination_cidr_block = "0.0.0.0/0"
  route_table_id  = aws_route_table.private_route_table[each.value.route_teble_name].id
  gateway_id = aws_nat_gateway.private[each.key].id
}
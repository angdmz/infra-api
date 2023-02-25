resource "aws_vpc" "network" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "network"
  }
}


resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.network.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "subnet"
  }
}


resource "aws_subnet" "rds_subnet" {
  vpc_id = aws_vpc.network.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.network.id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_vpc" "network" {
  cidr_block = "10.0.0.0/24"
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


resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.network.id
  cidr_block              = "10.1.0.0/22"
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
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "ecs_sg" {
  vpc_id      = aws_vpc.network.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.network.id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
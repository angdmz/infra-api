resource "aws_vpc" "network" {
  cidr_block = "10.0.0.0/16"

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
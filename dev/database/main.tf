locals {
  network_id = var.network_id
  subnet_id = var.subnet_id
}

resource "aws_db_instance" "database_instance" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.7"
  instance_class       = "db.t2.micro"
  db_name              = "my-db-instance"
  username             = "my-db-username"
  password             = "my-db-password"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = subnet_id
}
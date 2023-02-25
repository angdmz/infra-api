locals {
  network_id = var.network_id
  subnet_az1_id = var.subnet_az1_id
  subnet_az2_id = var.subnet_az2_id
  subnet_az3_id = var.subnet_az3_id
  runtime_security_id = var.runtime_security_id
}

resource "aws_db_instance" "database_instance" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "12.7"
  instance_class       = "db.t2.micro"
  db_name              = "main"
  username             = "user"
  password             = "pass"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_sg.id, local.runtime_security_id]
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [local.subnet_az1_id, local.subnet_az2_id, local.subnet_az3_id]
}

resource "aws_security_group" "rds_sg" {
  vpc_id      = local.network_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [local.runtime_security_id]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
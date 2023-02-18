locals {
  network_id = var.network_id
  subnet_id = var.subnet_id
}

# Create a security group for the ECS cluster
resource "aws_security_group" "ecs_security_group" {
  name_prefix = "ecs_sg_"
  vpc_id = network_id

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AWS managed policy for ECS tasks to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role = aws_iam_role.ecs_task_role.name
}

# Create an ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

# Create an EC2 launch template for the ECS instances
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix = "ecs_launch_template_"

  image_id = "ami-0f7919c1b6007a0bc" # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
              EOF
}

# Create an autoscaling group for the ECS instances
resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name_prefix = "ecs_asg_"
  launch_template {
    id = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  min_size = 1
  max_size = 3
  vpc_zone_identifier = [subnet_id]
  target_group_arns = []
}
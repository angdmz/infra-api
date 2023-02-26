locals {
  network_id = var.network_id
  subnet_id = var.subnet_id
}

resource "aws_security_group" "ecs_sg" {
  vpc_id      = local.network_id

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

data "aws_iam_policy_document" "ecs_agent_data" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent_role" {
  name               = "ecs-agent-infra-api-dev"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent_data.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent_attachment" {
  role       = aws_iam_role.ecs_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent-infra-api-dev"
  role = aws_iam_role.ecs_agent_role.name
}


data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "ecs_launch_config" {
  image_id = data.aws_ami.amazon_linux.id
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  user_data = base64encode("#!/bin/bash\necho ECS_CLUSTER=infra-api-dev-cluster >> /etc/ecs/ecs.config")
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                      = "asg"
  vpc_zone_identifier       = [local.subnet_id]
  launch_template {
    name = aws_launch_template.ecs_launch_config.name
  }
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 10
  health_check_grace_period = 300
  health_check_type         = "EC2"
}


resource "aws_ecr_repository" "repository" {
  name  = "infra-api-dev-repository"
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name  = "infra-api-dev-cluster"
}


resource "aws_ecs_task_definition" "task_definition" {
  family                = "runtimes"
  container_definitions = jsonencode(
    [
      {
        essential : true,
        memory : 512,
        name : "worker",
        cpu : 2,
        image : "hello-world:latest",
        environment : []
      }
    ]
  )
}


resource "aws_ecs_service" "worker_ecs_service" {
  name            = "runtimes"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
}
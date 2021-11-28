terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.67"
    }
  }

  backend "s3" {
    bucket = "personal-aws-tfstate"
    key    = "prometheus-gmail-exporter"
    region = "eu-west-1"
  }

  required_version = ">= 1.0.11"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"

  default_tags {
    tags = {
      managed_by          = "terraform"
      managing_repository = "github.com/richardtowers/personal-aws"
      managing_deployment = "prometheus-gmail-exporter"
    }
  }
}

// All of this is just to get a docker image running in ECS 😬

resource "aws_vpc" "personal" {
  tags = {
    Name = "personal"
  }
  cidr_block = "10.0.128.0/24"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.personal.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.personal.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.this.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_subnet" "public" {
  cidr_block = "10.0.128.0/26"
  vpc_id     = aws_vpc.personal.id
}

resource "aws_ecs_cluster" "personal" {
  name = "personal"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  capacity_providers = ["FARGATE_SPOT"]

}

resource "aws_cloudwatch_log_group" "this" {
  name              = "prometheus-gmail-exporter"
  retention_in_days = 7
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "prometheus_gmail_exporter_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_policy" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "prometheus_gmail_exporter" {
  cpu    = 256
  memory = 512

  execution_role_arn = aws_iam_role.task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "prometheus-gmail-exporter"
    image     = "ghcr.io/richardtowers/prometheus-gmail-exporter-go:v0.0.2"
    essential = true
    portMappings = [
      {
        containerPort = 2112
        hostPort      = 2112
      }
    ]
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.id,
        awslogs-region        = "eu-west-1",
        awslogs-stream-prefix = "container"
      }
    }
  }])
  requires_compatibilities = ["FARGATE"]
  family                   = "prometheus-gmail-exporter"
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "prometheus_gmail_exporter" {
  name            = "prometheus-gmail-exporter"
  cluster         = aws_ecs_cluster.personal.id
  task_definition = aws_ecs_task_definition.prometheus_gmail_exporter.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    assign_public_ip = true
  }
}

#
# ECS Cluster
#

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

# Cloudwatch
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${var.prefix}-logs"
}

# Task Policy/Role and Binding
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${var.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving of images and adding to logs"
  policy = templatefile("./templates/iam/task-exec-role.json",
    {
      logs_arn = aws_cloudwatch_log_group.ecs_task_logs.arn
      ssm_arn  = data.aws_ssm_parameter.dropbox_rclone_config.arn
  })
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.prefix}-task-exec-role"
  assume_role_policy = file("./templates/iam/ecs-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

# Container Policy/Role and Binding
resource "aws_iam_policy" "container_execution_role_policy" {
  name        = "${var.prefix}-container-exec-role-policy"
  path        = "/"
  description = "Allow S3"
  policy = templatefile("./templates/iam/container-exec-role.json",
    {
      s3_target_bucket = aws_s3_bucket.backups_dropbox.arn
  })
}

resource "aws_iam_role" "container_execution_role" {
  name               = "${var.prefix}-container-exec-role"
  assume_role_policy = file("./templates/iam/ecs-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "container_execution_role" {
  role       = aws_iam_role.container_execution_role.name
  policy_arn = aws_iam_policy.container_execution_role_policy.arn
}

# Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.prefix
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 2048
  container_definitions = templatefile("./templates/container-definitions.json",
    {
      name                  = "${var.prefix}"
      image                 = "${aws_ecr_repository.ecr_repo.repository_url}:${var.ecr_image_version}"
      dropbox_rclone_config = data.aws_ssm_parameter.dropbox_rclone_config.arn
      log_group_name        = aws_cloudwatch_log_group.ecs_task_logs.name
      log_group_region      = data.aws_region.current.name
      s3_target_bucket      = aws_s3_bucket.backups_dropbox.id
  })

  volume {
    name = "efs-vol"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
    }
  }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  execution_role_arn = aws_iam_role.task_execution_role.arn
  task_role_arn      = aws_iam_role.container_execution_role.arn
}

# Security group for ECS Task

resource "aws_security_group" "ecs_task" {
  description = "Access for the ECS Dropbox task"
  name        = "${var.prefix}-ecs-task"
  vpc_id      = aws_vpc.backups_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
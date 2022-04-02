#
# Cloudwatch triggered execution
#

resource "aws_iam_policy" "scheduled_task_cloudwatch_role_policy" {
  name        = "${var.prefix}-cloudwatch-scheduled-task-role-policy"
  path        = "/"
  description = "Allow execution of scheduled task"
  policy = templatefile("./templates/iam/cloudwatch-scheduled-task-policy.json",
    {
      ecs_task = "${replace(aws_ecs_task_definition.main.arn, "/:\\d+$/", ":*")}"
  })
}

resource "aws_iam_role" "scheduled_task_cloudwatch_role" {
  name               = "${var.prefix}-cloudwatch-role"
  assume_role_policy = file("./templates/iam/cloudwatch-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "scheduled_task_cloudwatch_role" {
  role       = aws_iam_role.scheduled_task_cloudwatch_role.name
  policy_arn = aws_iam_policy.scheduled_task_cloudwatch_role_policy.arn
}

resource "aws_cloudwatch_event_rule" "scheduled_task" {
  name                = "${var.prefix}-scheduled-ecs-event-rule"
  schedule_expression = var.backup_schedule
}

resource "aws_cloudwatch_event_target" "scheduled_task" {
  target_id = var.prefix
  rule      = aws_cloudwatch_event_rule.scheduled_task.name
  arn       = aws_ecs_cluster.main.arn
  role_arn  = aws_iam_role.scheduled_task_cloudwatch_role.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.main.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = [aws_subnet.backups_subnet.id]
      assign_public_ip = true
      security_groups  = [aws_security_group.ecs_task.id]
    }
  }
}
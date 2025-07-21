data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Execution Role
resource "aws_iam_role" "task_execution" {
  name               = "${local.project}-task-exec-role"
  description        = "Permissions to startup the container"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.task_execution.name
}

# Task Role
resource "aws_iam_role" "task_access" {
  name               = "${local.project}-task-access-role"
  description        = "Permissions to access aws services from within the container"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

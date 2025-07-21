data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip"

  source {
    content = templatefile("${path.module}/scripts/lambda.tftpl", {
      cluster_name         = local.context[terraform.workspace].ecs.cluster_name
      subnets              = jsonencode(module.vpc.private_subnets),
      security_group_ids   = jsonencode([module.https_sg.security_group_id]),
      task_definition_name = aws_ecs_task_definition.this.arn
    })
    filename = "lambda.js"
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:runTask"]
    resources = [aws_ecs_task_definition.this.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.task_access.arn, aws_iam_role.task_execution.arn]
  }
}

module "ansible_trigger" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~>v8.0"

  description            = "Trigger to run an ecs task"
  handler                = "lambda.handler"
  runtime                = "nodejs22.x"
  function_name          = local.project
  create_package         = false
  local_existing_package = data.archive_file.lambda.output_path
  attach_policy_json     = true
  policy_json            = data.aws_iam_policy_document.lambda.json
  tags                   = merge(local.tags, { "Name" : local.project })
}

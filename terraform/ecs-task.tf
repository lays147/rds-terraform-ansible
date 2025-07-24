module "ecs_container_definition" {
  source  = "terraform-aws-modules/ecs/aws//modules/container-definition"
  version = "~> 6.0"

  name                   = local.project
  cpu                    = local.context[terraform.workspace].ecs.cpu
  memory                 = local.context[terraform.workspace].ecs.memory
  essential              = true
  readonlyRootFilesystem = false
  image                  = "${aws_ecr_repository.this.repository_url}:${local.context[terraform.workspace].ecs.container_tag}"

  tags = local.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.project
  container_definitions    = module.ecs_container_definition.container_definition_json
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task_access.arn
  execution_role_arn       = aws_iam_role.task_execution.arn
  cpu                      = local.context[terraform.workspace].ecs.cpu
  memory                   = local.context[terraform.workspace].ecs.memory
  tags                     = local.tags
}

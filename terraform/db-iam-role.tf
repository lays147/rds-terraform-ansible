data "aws_iam_policy_document" "rds_connect" {
  statement {
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${local.region}:${data.aws_caller_identity.current.account_id}:dbuser:${module.aurora_postgresql_v2.cluster_resource_id}/${local.postgres.app_user}"]
  }
}

resource "aws_iam_role_policy" "rds_connect" {
  name   = "${local.project}-rds-connect-policy"
  role   = aws_iam_role.task_access.name
  policy = data.aws_iam_policy_document.rds_connect.json
}

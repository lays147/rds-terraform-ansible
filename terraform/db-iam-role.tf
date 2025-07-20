data "aws_iam_policy_document" "rds_iam" {
  statement {
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${local.region}:${data.aws_caller_identity.this.account_id}:dbuser:${module.db.cluster_resource_id}/${local.postgres.app_user}"]
  }
}

resource "aws_iam_role" "rds_iam_role" {
  name               = "${local.project}-rds-iam-role"
  assume_role_policy = data.aws_iam_policy_document.rds_iam.json
}
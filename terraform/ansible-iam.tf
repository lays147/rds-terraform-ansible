data "aws_iam_policy_document" "ansible_access" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [module.aurora_postgresql_v2.cluster_master_user_secret[0].secret_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["rds:DescribeDBClusters", "rds:ListTagsForResource"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ansible_access" {
  path   = "/${local.project}/"
  name   = "${local.project}-ansible-permissions"
  policy = data.aws_iam_policy_document.ansible_access.json
  tags   = local.tags
}

# Attach the policy to allow the container to query secrets and RDS
resource "aws_iam_role_policy_attachment" "ansible_access" {
  role       = aws_iam_role.task_access.name
  policy_arn = aws_iam_policy.ansible_access.arn
}

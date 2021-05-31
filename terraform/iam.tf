resource "aws_iam_role" "nextcloud_ecs_exec" {
  name               = "${local.nextcloud_namespaced_hostname}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.assumerole_nextcloud_ecs_exec.json
}

resource "aws_iam_role_policy_attachment" "nextcloud_ecs_exec" {
  role       = aws_iam_role.nextcloud_ecs_exec.name
  policy_arn = aws_iam_policy.nextcloud_ecs_exec.arn
}

resource "aws_iam_policy" "nextcloud_ecs_exec" {
  name   = "${local.nextcloud_namespaced_hostname}-ecs-execution"
  policy = data.aws_iam_policy_document.nextcloud_ecs_exec.json
}

data "aws_iam_policy_document" "assumerole_nextcloud_ecs_exec" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "nextcloud_ecs_exec" {
  statement {
    sid = "AllowRetrieveSecretsValuesFromParamStore"

    actions = [
      "ssm:GetParam*",
    ]

    resources = [
      aws_ssm_parameter.nextcloud_admin_passwd.arn,
      aws_ssm_parameter.nextcloud_db_passwd.arn,
    ]
  }

  statement {
    sid = "EnableParamStoreDecryptSecretValues"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      aws_kms_alias.nextcloud.arn,
    ]
  }
}

resource aws_iam_role owncloud_ecs_exec {
  name               = "${local.owncloud_namespaced_hostname}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.assumerole_owncloud_ecs_exec.json
}

resource aws_iam_role_policy_attachment owncloud_ecs_exec {
  role       = aws_iam_role.owncloud_ecs_exec.name
  policy_arn = aws_iam_policy.owncloud_ecs_exec.arn
}

resource aws_iam_policy owncloud_ecs_exec {
  name   = "${local.owncloud_namespaced_hostname}-ecs-execution"
  policy = data.aws_iam_policy_document.owncloud_ecs_exec.json
}

data aws_iam_policy_document assumerole_owncloud_ecs_exec {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data aws_iam_policy_document owncloud_ecs_exec {
  statement {
    sid = "AllowRetrieveSecretsValuesFromParamStore"

    actions = [
      "ssm:GetParam*",
    ]

    resources = [
      aws_ssm_parameter.owncloud_admin_passwd.arn,
      aws_ssm_parameter.owncloud_db_passwd.arn,
    ]
  }

  statement {
    sid = "EnableParamStoreDecryptSecretValues"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      aws_kms_alias.owncloud.arn,
    ]
  }
}

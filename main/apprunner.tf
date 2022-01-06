resource "aws_apprunner_service" "nextcloud" {
  service_name = "nextcloud"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner.arn
    }
    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "${data.aws_ecr_repository.nextcloud.repository_url}:latest"
      image_repository_type = "ECR"
    }
  }
}

resource "aws_iam_role" "apprunner" {
  name_prefix        = "nextcloud-apprunner-"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_apprunner.json
}

data "aws_iam_policy_document" "apprunner" {
  statement {
    sid = "AllowWriteLogsToCloudWatch"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowPullFromECR"
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "apprunner" {
  role   = aws_iam_role.apprunner.name
  policy = data.aws_iam_policy_document.apprunner.json
}

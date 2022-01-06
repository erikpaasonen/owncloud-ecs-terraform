data "aws_ecr_repository" "nextcloud" {
  name = "nextcloud"
}

data "aws_iam_policy_document" "trust_policy_apprunner" {
  statement {
    sid = "AllowCodeBuildSvcToAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_caller_identity" "current" {
}

data "aws_iam_policy_document" "trust_policy_codebuild" {
  statement {
    sid = "AllowCodeBuildSvcToAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_region" "current" {
}

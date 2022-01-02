resource "aws_iam_role" "nc_cicd" {
  name_prefix        = "nextcloud-cicd-"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_codebuild.json
}

data "aws_iam_policy_document" "cicd" {
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
    sid = "AllowRetrieveArtifactFromS3"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${var.s3_bucket_arn}/artifacts/*",
    ]
  }

  statement {
    sid = "AllowPushDockerImgToECR"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      var.ecr_repo.arn,
    ]
  }

  statement {
    sid = "AllowGetAuthToken"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "nc_cicd" {
  role   = aws_iam_role.nc_cicd.name
  policy = data.aws_iam_policy_document.cicd.json
}

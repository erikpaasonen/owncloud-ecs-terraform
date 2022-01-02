data "aws_availability_zones" "current" {
  state = "available"
}

data "aws_iam_policy_document" "trust_policy_apprunner" {
  statement {
    sid = "AllowCodeBuildSvcToAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["apprunner.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

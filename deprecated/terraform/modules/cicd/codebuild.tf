resource "aws_codebuild_project" "build_db" {
  name         = "build-nextcloud-db"
  description  = "builds a Nextcloud database server image from Ubuntu AMI"
  service_role = aws_iam_role.codebuild_db.arn

  artifacts {
    type           = "S3"
    location       = aws_s3_bucket.cicd.name
    path           = "/artifacts/"
    packaging      = "NONE"
    namespace_type = "BUILD_ID"
  }

  environment {
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "hashicorp/packer:latest"

    # probably superceded by inline buildspec def below
    environment_variable {
      name  = "random_pet"
      value = random_pet.nextcloud.id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.cicd_build_logs.name
    }
  }

  source {
    buildspec = jsonencode({
      version = 0.2

      env = {
        variables = {
          PKR_VAR_random_pet           = random_pet.nextcloud.id
          PKR_VAR_region               = var.region
          PKR_VAR_ssh_pub_key_material = var.public_key_material
          DEBIAN_FRONTEND              = "noninteractive"
        }
      }

      phases = {
        build = {
          commands = [
            "packer build db.pkr.hcl"
          ]
        }
      }

      reports = {
        files = [
          "./"
        ]
      }
    })
  }
}

resource "aws_iam_role" "codebuild_db" {
  name_prefix        = "codebuild-db-"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_codebuild.json

  inline_policy {
    name   = "AllowCodeBuildStandardPermissions"
    policy = data.aws_iam_policy_document.codebuild_db.json
  }
}

data "aws_iam_policy_document" "codebuild_db" {
  statement {
    sid = "AllowLogToCloudWatch"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowVpcStuff"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowCreateNetworkIfaceInVpc"
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = ["arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }
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

resource "aws_cloudwatch_log_group" "cicd_build_logs" {
  name_prefix       = "codebuild-db-"
  retention_in_days = 5
}

resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_pat
}

resource "aws_codebuild_project" "build_push_to_ecr" {
  name           = "${var.nextcloud_namespaced_hostname}-build-push-to-ecr"
  description    = "build Nextcloud server Docker image and push to ECR"
  build_timeout  = "5"
  queued_timeout = "5"

  service_role = aws_iam_role.nc_cicd.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repo.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  source {
    type     = "S3"
    location = "${var.s3_bucket_arn}/artifacts/Dockerfile.zip"
    buildspec = jsonencode({
      version = 0.2
      phases = {
        pre_build = {
          commands = [
            "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
          ]
        }
        build = {
          commands = [
            "docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .",
            "docker tag $IMAGE_REPO_NAME:$IMAGE_TAG ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG",
            "",
          ]
        }
        post_build = {
          commands = [
            "docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG",
          ]
        }
      }
    })
  }
}

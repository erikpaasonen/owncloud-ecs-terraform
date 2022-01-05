resource "aws_codebuild_project" "build_push_to_ecr" {
  name           = "${var.nextcloud_namespaced_hostname}-build-push-to-ecr"
  description    = "build Nextcloud server Docker image and push to ECR"
  build_timeout  = "5"
  queued_timeout = "5"

  service_role = aws_iam_role.nc_cicd.arn

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true // necessary to build Docker images

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_repo.name
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "ECR_URL"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }

    environment_variable {
      name  = "MYSQL_PASS_FROM_PARAMSTORE"
      type  = "PARAMETER_STORE"
      value = var.parampath_mysql_passwd
    }

    environment_variable {
      name  = "NEXTCLOUD_ADMIN_PASS_FROM_PARAMSTORE"
      type  = "PARAMETER_STORE"
      value = var.parampath_nc_admin_passwd
    }

    environment_variable {
      name  = "OBJSTORE_SECRET_FROM_PARAMSTORE"
      type  = "PARAMETER_STORE"
      value = var.parampath_obj_store_s3_secret
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
            "aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URL",
            "echo $CODEBUILD_BUILD_ID",
            "export CB_EXEC_ID=$(echo $CODEBUILD_BUILD_ID | cut -d ':' -f2)",
            "echo $CB_EXEC_ID",
          ]
        }
        build = {
          commands = [
            "docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .",
            "docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $ECR_URL/$IMAGE_REPO_NAME:$CB_EXEC_ID",
            "docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $ECR_URL/$IMAGE_REPO_NAME:$IMAGE_TAG",
          ]
        }
        post_build = {
          commands = [
            "docker push $ECR_URL/$IMAGE_REPO_NAME:$IMAGE_TAG",
            "docker push $ECR_URL/$IMAGE_REPO_NAME:$CB_EXEC_ID",
          ]
        }
      }
    })
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }
}

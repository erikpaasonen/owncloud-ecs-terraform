resource "aws_apprunner_service" "nextcloud" {
  service_name = "nextcloud"

  source_configuration {
    image_repository {
      image_configuration {
        port = "80"
      }
      image_identifier      = "public.ecr.aws/jg/hello:latest"
      image_repository_type = "ECR"
    }
  }
}

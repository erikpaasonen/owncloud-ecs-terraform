resource "aws_ecr_repository" "nextcloud" {
  name = "nextcloud"
  encryption_configuration {
    encryption_type = "KMS"
  }
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

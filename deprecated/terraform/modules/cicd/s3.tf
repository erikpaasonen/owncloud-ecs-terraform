resource "aws_s3_bucket" "cicd" {
  name_prefix = "nextcloud-cicd-"

  lifecycle_rule {
    enabled = true
    id      = "codebuild"
    prefix  = "codebuild/"

    transition {
      days          = 1
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 90
    }
  }

  lifecycle_rule {
    enabled = true
    id      = "artifacts"
    prefix  = "artifacts/"

    transition {
      days          = 1
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

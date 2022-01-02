resource "aws_s3_bucket" "nextcloud_datastore" {
  bucket_prefix = "${local.nextcloud_namespaced_hostname}-"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "nextcloud_datastore" {
  bucket = aws_s3_bucket.nextcloud_datastore.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "create_dockerfile" {
  type                    = "zip"
  output_path             = "${path.module}/Dockerfile.zip"
  source_content_filename = "Dockerfile"
  source_content          = <<DOCKERFILE
FROM nextcloud:latest

ENV MYSQL_DATABASE=${module.rds.instance.name}
ENV MYSQL_USER=${module.rds.instance.username}
ENV MYSQL_PASSWORD=${module.rds.instance.password}
ENV MYSQL_HOST=${module.rds.instance.endpoint}

ENV NEXTCLOUD_ADMIN_USER=${random_pet.nc_admin_username.id}
ENV NEXTCLOUD_ADMIN_PASSWORD=${random_password.nc_admin_password.result}

ENV REDIS_HOST=${aws_elasticache_cluster.nextcloud.cache_nodes[0].address}

ENV OBJECTSTORE_S3_BUCKET=${aws_s3_bucket.nextcloud_datastore.bucket}
ENV OBJECTSTORE_S3_KEY=${aws_iam_access_key.nc_data.id}
ENV OBJECTSTORE_S3_SECRET=${aws_iam_access_key.nc_data.secret}
DOCKERFILE

}

resource "aws_s3_bucket_object" "create_dockerfile" {
  bucket                 = aws_s3_bucket.nextcloud_datastore.bucket
  key                    = "artifacts/Dockerfile.zip"
  server_side_encryption = "aws:kms"

  source = data.archive_file.create_dockerfile.output_path
}

data "archive_file" "create_dockerfile" {
  type                    = "zip"
  output_path             = "${path.module}/Dockerfile.zip"
  source_content_filename = "Dockerfile"
  source_content          = <<DOCKERFILE
FROM nextcloud:latest

ENV MYSQL_DATABASE=${module.rds.instance.name} \
  MYSQL_USER=${module.rds.instance.username} \
  MYSQL_HOST=${module.rds.instance.endpoint} \
  MYSQL_PASSWORD='$MYSQL_PASS_FROM_PARAMSTORE' \
  NEXTCLOUD_ADMIN_USER=${random_pet.nc_admin_username.id} \
  NEXTCLOUD_ADMIN_PASSWORD='$NEXTCLOUD_ADMIN_PASS_FROM_PARAMSTORE' \
  REDIS_HOST=${aws_elasticache_cluster.nextcloud.cache_nodes[0].address} \
  OBJECTSTORE_S3_BUCKET=${aws_s3_bucket.nextcloud_datastore.bucket} \
  OBJECTSTORE_S3_KEY=${aws_iam_access_key.nc_data.id} \
  OBJECTSTORE_S3_SECRET='$OBJSTORE_SECRET_FROM_PARAMSTORE'
DOCKERFILE

}

resource "aws_s3_bucket_object" "create_dockerfile" {
  bucket                 = aws_s3_bucket.artifacts.bucket
  key                    = "artifacts/Dockerfile.zip"
  server_side_encryption = "aws:kms"

  source      = data.archive_file.create_dockerfile.output_path
  source_hash = data.archive_file.create_dockerfile.output_base64sha256
}

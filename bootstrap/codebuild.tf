module "codebuild" {
  source = "./modules/codebuild"

  nextcloud_namespaced_hostname = local.nextcloud_namespaced_hostname
  s3_bucket_arn                 = aws_s3_bucket.nextcloud_datastore.arn
  ecr_repo = {
    arn  = aws_ecr_repository.nextcloud.arn
    name = aws_ecr_repository.nextcloud.name
  }
}

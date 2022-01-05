module "codebuild" {
  source = "./modules/codebuild"

  nextcloud_namespaced_hostname = local.nextcloud_namespaced_hostname
  s3_bucket_arn                 = aws_s3_bucket.artifacts.arn
  ecr_repo = {
    arn  = aws_ecr_repository.nextcloud.arn
    name = aws_ecr_repository.nextcloud.name
  }
  parampath_mysql_passwd        = aws_ssm_parameter.mysql_passwd.name
  parampath_nc_admin_passwd     = aws_ssm_parameter.nc_admin_passwd.name
  parampath_obj_store_s3_secret = aws_ssm_parameter.obj_store_s3_secret.name
}

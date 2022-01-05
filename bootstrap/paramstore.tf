resource "aws_ssm_parameter" "mysql_passwd" {
  name      = "/auth/nextcloud/MYSQL_PASSWORD"
  type      = "SecureString"
  value     = module.rds.instance.password
  overwrite = true
}

resource "aws_ssm_parameter" "nc_admin_passwd" {
  name      = "/auth/nextcloud/NEXTCLOUD_ADMIN_PASSWORD"
  type      = "SecureString"
  value     = random_password.nc_admin_password.result
  overwrite = true
}

resource "aws_ssm_parameter" "obj_store_s3_secret" {
  name      = "/auth/nextcloud/OBJECTSTORE_S3_SECRET"
  type      = "SecureString"
  value     = aws_iam_access_key.nc_data.secret
  overwrite = true
}

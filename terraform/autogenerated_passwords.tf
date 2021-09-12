locals {
  paramstore_creds_path = "/creds/nextcloud/${random_pet.nextcloud.id}"
}

resource "random_password" "nextcloud_admin" {
  length = 30
}

resource "aws_ssm_parameter" "nextcloud_admin_passwd" {
  name        = "${local.paramstore_creds_path}/admin_passwd"
  description = "securely storing the password for the nextcloud admin user"

  type      = "SecureString"
  key_id    = aws_kms_alias.nextcloud.target_key_arn
  value     = random_password.nextcloud_admin.result
  overwrite = true
}

resource "random_password" "nextcloud_db" {
  length = 30
}

resource "aws_ssm_parameter" "nextcloud_db_passwd" {
  name        = "${local.paramstore_creds_path}/db_passwd"
  description = "securely storing the password for the nextcloud db user"

  type      = "SecureString"
  key_id    = aws_kms_alias.nextcloud.target_key_arn
  value     = random_password.nextcloud_db.result
  overwrite = true
}

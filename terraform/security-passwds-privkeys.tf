locals {
  paramstore_creds_path = "/creds/nextcloud_test/${random_pet.this.id}"
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

resource "random_password" "nextcloud_rds_db" {
  length           = 30
  number           = true
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "nextcloud_ssh_priv_key" {
  count = local.custom_ssh_key_material_provided ? 0 : 1

  name        = "${local.paramstore_creds_path}/ssh_priv_key_material"
  description = "SSH private key generated by Terraform for the nextcloud test activity"

  type      = "SecureString"
  key_id    = aws_kms_alias.nextcloud.target_key_arn
  value     = tls_private_key.nextcloud[0].private_key_pem
  overwrite = true
}

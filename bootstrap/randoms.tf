# this is unfortunately a pet, not cattle, so let's have fun with that fact
resource "random_pet" "nextcloud" {
}

resource "random_pet" "nc_admin_username" {
  separator = ""
}

resource "random_password" "nc_admin_password" {
  length = 30
}

resource "aws_ssm_parameter" "nc_admin_password" {
  name        = "/creds/nextcloud/${random_pet.nextcloud.id}/admin_passwd"
  description = "securely storing the password for the nextcloud admin user"

  type      = "SecureString"
  value     = random_password.nc_admin_password.result
  overwrite = true
}

locals {
  public_key_material = length(var.ssh_public_key_material) == 0 ? tls_private_key.owncloud[0].public_key_openssh : var.ssh_public_key_material
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_pet.owncloud.id}"
  public_key = local.public_key_material
}

resource tls_private_key owncloud {
  count = length(var.ssh_public_key_material) == 0 ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource aws_ssm_parameter owncloud_ssh_priv_key {
  count = length(var.ssh_public_key_material) == 0 ? 1 : 0

  name        = "/creds/owncloud_test/${random_pet.owncloud.id}/ssh_priv_key_material"
  description = "SSH private key generated by Terraform for the OwnCloud test activity"

  type      = "SecureString"
  value     = tls_private_key.owncloud[0].private_key_pem
  overwrite = true
}

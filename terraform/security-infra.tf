module "custom_domain" {
  count  = local.custom_domain_used ? 1 : 0
  source = "../modules/custom_domain"

  r53_domain_name = var.r53_domain_name
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_pet.this.id}"
  public_key = local.public_key_material
}

resource "tls_private_key" "nextcloud" {
  count = local.custom_ssh_key_material_provided ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_kms_key" "nextcloud" {
}

resource "aws_kms_alias" "nextcloud" {
  name_prefix   = "alias/${local.nextcloud_namespaced_hostname}-"
  target_key_id = aws_kms_key.nextcloud.key_id
}

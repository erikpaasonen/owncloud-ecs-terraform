module "custom_domain" {
  for_each = toset(compact([var.r53_domain_name]))
  source = "../modules/custom_domain"

  r53_domain_name = var.r53_domain_name
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_pet.this.id}"
  public_key = local.public_key_material
}

resource "aws_kms_key" "nextcloud" {
}

resource "aws_kms_alias" "nextcloud" {
  name_prefix   = "alias/${local.nextcloud_namespaced_hostname}-"
  target_key_id = aws_kms_key.nextcloud.key_id
}

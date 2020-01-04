locals {
  public_key_material = length(var.ssh_public_key_material) == 0 ? tls_private_key.owncloud[0].public_key_openssh : var.ssh_public_key_material
}

resource aws_acm_certificate owncloud {
  count = local.custom_domain_used ? 1 : 0

  domain_name       = "owncloud.${var.r53_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data aws_route53_zone zone {
  count = local.custom_domain_used ? 1 : 0

  name         = var.r53_domain_name
  private_zone = false
}

resource aws_route53_record cert_validation {
  count = local.custom_domain_used ? 1 : 0

  name    = aws_acm_certificate.owncloud[0].domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.owncloud[0].domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.zone[0].id
  records = [aws_acm_certificate.owncloud[0].domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource aws_acm_certificate_validation cert {
  count = local.custom_domain_used ? 1 : 0

  certificate_arn         = aws_acm_certificate.owncloud[0].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
}

resource aws_key_pair deployer {
  key_name   = "deployer-key-${random_pet.this.id}"
  public_key = local.public_key_material
}

resource tls_private_key owncloud {
  count = local.custom_ssh_key_material_provided ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource aws_kms_key owncloud {
}

resource aws_kms_alias owncloud {
  name_prefix   = "alias/${local.owncloud_namespaced_hostname}-"
  target_key_id = aws_kms_key.owncloud.key_id
}

resource "aws_acm_certificate" "nextcloud" {
  domain_name       = "nextcloud.${var.r53_domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.nextcloud.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

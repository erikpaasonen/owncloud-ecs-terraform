data "aws_route53_zone" "zone" {
  name         = var.r53_domain_name
  private_zone = false
}

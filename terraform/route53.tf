module "custom_domain" {
  for_each = toset(compact([var.r53_domain_name]))
  source   = "../modules/custom_domain"

  r53_domain_name = var.r53_domain_name
}

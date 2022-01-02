output "cache_nodes" {
  value = module.common.cache_nodes
}

# output "dns_fqdn" {
#   value = module.common.dns_fqdn
# }

output "ecr_arn" {
  value = module.common.ecr_arn
}

output "redis_host" {
  value = module.common.redis_host
}

output "s3_bucket" {
  value = module.common.s3_bucket
}

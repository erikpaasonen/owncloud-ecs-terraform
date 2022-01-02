output "cache_nodes" {
  value = aws_elasticache_cluster.nextcloud.cache_nodes
}

# output "dns_fqdn" {
#   value = aws_route53_record.http.fqdn
# }

output "ecr_arn" {
  value = aws_ecr_repository.nextcloud.arn
}

output "redis_host" {
  value = aws_elasticache_cluster.nextcloud.cluster_id
}

output "s3_bucket" {
  value = aws_s3_bucket.nextcloud_datastore.bucket
}

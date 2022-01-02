resource "aws_elasticache_cluster" "nextcloud" {
  cluster_id           = local.nextcloud_namespaced_hostname
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.nextcloud.name
  engine_version       = "6.x"
  port                 = 6379
  security_group_ids   = [aws_security_group.nextcloud_redis_access.id]
  subnet_group_name    = aws_elasticache_subnet_group.nextcloud.name
}

resource "aws_elasticache_parameter_group" "nextcloud" {
  name   = "nextcloud-params"
  family = "redis6.x"

  # parameter {
  #   name  = "activerehashing"
  #   value = "yes"
  # }
}

resource "aws_security_group" "nextcloud_redis_access" {
  name        = "${local.nextcloud_namespaced_hostname}-redis-access"
  description = "Attach this SG to resources to allow them to access Redis"
  vpc_id      = module.vpc.vpc_id

  # allow redis instances to communicate openly with each other
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # allow redis instances to communicate openly with each other
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}

resource "aws_elasticache_subnet_group" "nextcloud" {
  name       = local.nextcloud_namespaced_hostname
  subnet_ids = module.vpc.private_subnets
}

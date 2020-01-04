resource aws_db_subnet_group rds {
  name        = "${local.owncloud_namespaced_hostname}-rds-subnet-group"
  description = "RDS subnet group for the RDS database used by OwnCloud"
  subnet_ids  = module.vpc.private_subnets
}

resource aws_db_instance rds {
  identifier_prefix = "${local.owncloud_namespaced_hostname}-db-"
  engine            = "mariadb"
  engine_version    = "10.3"
  instance_class    = "db.t3.micro"
  multi_az          = var.rds_multi_az
  name              = "owncloud"

  # parameter_group_name = aws_db_parameter_group.owncloud.name

  # allocated_storage = var.allocated_storage
  allocated_storage     = 20
  max_allocated_storage = 100

  kms_key_id        = aws_kms_key.owncloud.arn
  storage_encrypted = true
  username          = random_pet.owncloud_rds_db_username.id
  password          = random_password.owncloud_rds_db.result

  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
  ]

  db_subnet_group_name = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [
    aws_security_group.rds_enablement.id,
    aws_security_group.egress.id,
  ]

  skip_final_snapshot       = true
  final_snapshot_identifier = "rds-${local.owncloud_namespaced_hostname}-snapshot"
}

resource random_pet owncloud_rds_db_username {
  separator = ""
}

# resource aws_db_parameter_group owncloud {
#   name_prefix = "${local.owncloud_namespaced_hostname}-db-"
#   family      = "mariadb"

#   # parameter {
#   #   name  = "character_set_server"
#   #   value = "utf8"
#   # }

#   # parameter {
#   #   name  = "character_set_client"
#   #   value = "utf8"
#   # }
# }

# resource aws_db_option_group owncloud {
#   name_prefix              = "${local.owncloud_namespaced_hostname}-db-"
#   option_group_description = "culled from OwnCloud Enterprise Docker Compose file" // https://doc.owncloud.org/server/10.3/admin_manual/installation/docker/
#   engine_name              = "mariadb"
#   major_engine_version     = "10.3"

#   option {
#     option_name = "max-allowed-packet"

#     option_settings {
#       name  = "MARIADB_MAX_ALLOWED_PACKET"
#       value = "128M"
#     }
#   }

#   option {
#     option_name = "max-logfile-size"

#     option_settings {
#       name  = "MARIADB_INNODB_LOG_FILE_SIZE"
#       value = "64M"
#     }
#   }

#   # option {
#   #   option_name                   = "attach-security-groups"
#   #   db_security_group_memberships = [aws_security_group.rds_enablement.id]

#   #   # option_settings {
#   #   #   name  = "TIME_ZONE"
#   #   #   value = "UTC"
#   #   # }
#   # }
# }

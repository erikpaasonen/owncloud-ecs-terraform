resource "aws_db_subnet_group" "rds" {
  name        = var.namespaced_hostname
  description = "RDS subnet group for the RDS database used by nextcloud"
  subnet_ids  = var.vpc.private_subnet_ids
}

resource "aws_db_instance" "rds" {
  identifier_prefix    = "${var.namespaced_hostname}-"
  engine               = data.aws_rds_engine_version.default.engine
  engine_version       = data.aws_rds_engine_version.default.version
  instance_class       = "db.t3.micro"
  multi_az             = var.rds_multi_az
  name                 = "nextcloud"
  parameter_group_name = aws_db_parameter_group.nextcloud.name
  allocated_storage    = 20
  # max_allocated_storage = 100
  storage_encrypted = true
  storage_type      = "standard"
  apply_immediately = true

  username = random_pet.db_username.id
  password = random_password.rds_db.result

  enabled_cloudwatch_logs_exports = [
    # "audit",
    "error",
  ]

  db_subnet_group_name = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [
    aws_security_group.rds_enablement.id,
  ]

  skip_final_snapshot       = true
  final_snapshot_identifier = "rds-${var.namespaced_hostname}-snapshot"
}

resource "aws_db_parameter_group" "nextcloud" {
  name_prefix = "${var.namespaced_hostname}-db-"
  family      = data.aws_rds_engine_version.default.parameter_group_family

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

# resource "aws_db_option_group" "nextcloud" {
#   name_prefix              = "${var.namespaced_hostname}-db-"
#   option_group_description = "culled from nextcloud Enterprise Docker Compose file" // https://doc.nextcloud.org/server/10.3/admin_manual/installation/docker/
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

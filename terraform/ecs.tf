# resource aws_ecr_repository owncloud {
#   name = "owncloud"
# }

resource aws_ecs_cluster owncloud {
  name = local.owncloud_namespaced_hostname
}

resource aws_ecs_task_definition owncloud_service {
  family       = "owncloud-service-${random_pet.this.id}"
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.owncloud_ecs_exec.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = 256 # 0.25CPU
  memory                   = 512 # MiB

  volume {
    name = "files"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
    }
  }

  volume {
    name = "redis"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
    }
  }

  container_definitions = templatefile(
    "ecs_taskdef_owncloud_svc.json",
    {
      "owncloud_clientaccess_fqdn" : "${local.owncloud_namespaced_hostname}.${var.r53_domain_name}",
      "owncloud_hostname" : local.owncloud_namespaced_hostname,
      "owncloud_db_hostname" : aws_db_instance.rds.address,
      "owncloud_db_db_name" : aws_db_instance.rds.name,
      "owncloud_db_username" : aws_db_instance.rds.username,
      "owncloud_redis_hostname" : local.owncloud_namespaced_redis_hostname,
      "owncloud_version" : var.owncloud_version,
      "paramstore_admin_pwd" : aws_ssm_parameter.owncloud_admin_passwd.arn,
      "paramstore_db_pwd" : aws_ssm_parameter.owncloud_db_passwd.arn
    }
  )
}










# resource aws_ecs_task_definition owncloud_redis {
#   family       = "owncloud-redis-${random_pet.this.id}"
#   network_mode = "awsvpc"

#   requires_compatibilities = ["FARGATE"]
#   cpu                      = 256 # 0.25CPU
#   memory                   = 512 # MiB

#   volume {
#     name      = "redis"
#     host_path = "/var/lib/redis"

#     docker_volume_configuration {
#       scope         = "shared"
#       autoprovision = true
#     }
#   }

#   container_definitions = file("owncloud_redis.json")
# }

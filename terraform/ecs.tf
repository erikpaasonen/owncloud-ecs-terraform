# resource aws_ecr_repository nextcloud {
#   name = "nextcloud"
# }

resource "aws_ecs_cluster" "nextcloud" {
  name = local.nextcloud_namespaced_hostname
}

resource "aws_ecs_task_definition" "nextcloud_service" {
  family       = "nextcloud-service-${random_pet.this.id}"
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.nextcloud_ecs_exec.arn

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
    "${path.module}/ecs_taskdef_nextcloud_svc.json",
    {
      "nextcloud_clientaccess_fqdn" : "${local.nextcloud_namespaced_hostname}.${var.r53_domain_name}",
      "nextcloud_hostname" : local.nextcloud_namespaced_hostname,
      "nextcloud_db_hostname" : aws_db_instance.rds.address,
      "nextcloud_db_db_name" : aws_db_instance.rds.name,
      "nextcloud_db_username" : aws_db_instance.rds.username,
      "nextcloud_redis_hostname" : local.nextcloud_namespaced_redis_hostname,
      "nextcloud_version" : var.nextcloud_version,
      "paramstore_admin_pwd" : aws_ssm_parameter.nextcloud_admin_passwd.arn,
      "paramstore_db_pwd" : aws_ssm_parameter.nextcloud_db_passwd.arn
    }
  )
}










# resource aws_ecs_task_definition nextcloud_redis {
#   family       = "nextcloud-redis-${random_pet.this.id}"
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

#   container_definitions = file("nextcloud_redis.json")
# }

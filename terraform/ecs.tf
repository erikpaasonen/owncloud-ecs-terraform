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

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.nextcloud_files.id
      transit_encryption = "ENABLED"
    }
  }

  volume {
    name = "redis"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.nextcloud_redis.id
      transit_encryption = "ENABLED"
    }
  }

  container_definitions = jsonencode([
  {
    "name": "main-service",
    "image": "nextcloud/server:${var.nextcloud_version}",
    "cpu": 128,
    "memory": 256,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "nextcloud_DOMAIN",
        "value": "${local.nextcloud_namespaced_hostname}.${var.r53_domain_name}"
      },
      {
        "name": "nextcloud_DB_HOST",
        "value": aws_db_instance.rds.address
      },
      {
        "name": "nextcloud_DB_TYPE",
        "value": var.rds_engine_type
      },
      {
        "name": "nextcloud_DB_NAME",
        "value": aws_db_instance.rds.name
      },
      {
        "name": "nextcloud_DB_USERNAME",
        "value": aws_db_instance.rds.username
      },
      {
        "name": "nextcloud_ENABLE_CERTIFICATE_MANAGEMENT",
        "value": "true"
      },
      {
        "name": "nextcloud_REDIS_ENABLED",
        "value": "true"
      },
      {
        "name": "nextcloud_REDIS_HOST",
        "value": local.nextcloud_namespaced_redis_hostname
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "files",
        "containerPath": "/mnt/data"
      }
    ],
    "secrets": [
      {
        "name": "nextcloud_ADMIN_PASSWORD",
        "valueFrom": aws_ssm_parameter.nextcloud_admin_passwd.arn
      }
    ],
    "privileged": false,
    "readonlyRootFilesystem": true,
    "healthCheck": {
      "command": [
        "/usr/bin/healthcheck"
      ],
      "interval": 30,
      "timeout": 10,
      "retries": 5
    }
  },
  {
    "name": "redis",
    "image": "webhippie/redis:latest",
    "cpu": 128,
    "memory": 256,
    "essential": true,
    "environment": [
      {
        "name": "REDIS_DATABASES",
        "value": "1"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "redis",
        "containerPath": "/var/lib/redis"
      }
    ],
    "privileged": false,
    "readonlyRootFilesystem": true,
    "healthCheck": {
      "command": [
        "/usr/bin/healthcheck"
      ],
      "interval": 30,
      "timeout": 10,
      "retries": 5
    }
  }
  ])
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

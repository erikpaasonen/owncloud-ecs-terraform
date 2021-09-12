resource "aws_efs_file_system" "nextcloud_files" {
  creation_token = "nextcloud-service-${random_pet.nextcloud.id}"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

resource "aws_efs_file_system" "nextcloud_redis" {
  creation_token = "nextcloud-redis-${random_pet.nextcloud.id}"

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

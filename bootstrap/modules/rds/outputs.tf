output "instance" {
  value = {
    address           = aws_db_instance.rds.address
    endpoint          = aws_db_instance.rds.endpoint
    name              = aws_db_instance.rds.name
    password          = aws_db_instance.rds.password
    port              = aws_db_instance.rds.port
    status            = aws_db_instance.rds.status
    storage_encrypted = aws_db_instance.rds.storage_encrypted
    username          = aws_db_instance.rds.username
  }
}

output "db_name" {
  value = aws_db_instance.rds.name
}

output "db_username" {
  value = random_pet.db_username.id
}

output "hosted_zone_id" {
  value = aws_db_instance.rds.hosted_zone_id
}

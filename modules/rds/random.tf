resource "random_pet" "rds_db_username" {
  separator = ""
}

resource "random_password" "rds_db" {
  length           = 30
  number           = true
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

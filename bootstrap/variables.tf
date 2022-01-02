locals {
  custom_domain_used            = tobool(length(var.r53_domain_name) > 0)
  nextcloud_namespaced_hostname = "nextcloud-${random_pet.nextcloud.id}"
}

variable "nextcloud_version" {
  type        = string
  description = "The version of nextcloud to install"
  default     = "latest"
}

variable "r53_domain_name" {
  type        = string
  description = "If you want your nextcloud FQDN to utilize a domain hosted with AWS in Route 53, specify it here; otherwise, leave blank"
  default     = ""
}

variable "rds_engine_type" {
  type        = string
  description = "Valid RDS engine type value acceptable by the AWS RDS API."
  default     = "mariadb"
}

variable "rds_multi_az" {
  type        = bool
  description = "Whether the RDS instance should span multiple availability zones; may impact cost"
  default     = false
}

variable "vpc_cidr" {
  type        = string
  description = "subnet specified in CIDR format (e.g. 10.0.0.0/24) to be used as the base CIDR for the VPC"
  default     = "10.0.0.0/24"
}

variable "vpc_subnet_count" {
  type        = number
  description = "positive integer count of how many public/private pairs of subnets are desired; if more than the number of available AZs, the number of AZs will override this"
  default     = 4
}

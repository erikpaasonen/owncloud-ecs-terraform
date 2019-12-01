variable mgmt_ip {
  type        = string
  description = "IP address from which the OwnCloud instance will be managed"
  default     = ""
}

variable owncloud_version {
  type        = string
  description = "The version of OwnCloud to install"
  default     = "latest"
}

variable owncloud_domain {
  type        = string
  description = "The domain to configure in OwnCloud; note NOT an Active Directory domain, NOT related to RDS"
  default     = "localhost"
}

# variable rds_allocated_storage {
#   type = number
#   description = "Number of gigabytes for the initial size of the RDS database"
#   default = 20
# }

variable region {
  type        = string
  description = "Name of the AWS region where these resources should go"
  default     = "us-east-1"
}

variable ssh_public_key_material {
  type        = string
  description = "The public key of an SSH key pair to be used to admin the EC2 instance; if none provided, one will be generated and its private key stored in Parameter Store"
  default     = ""
}

variable vpc_cidr {
  type        = string
  description = "subnet specified in CIDR format (e.g. 10.0.0.0/24) to be used as the base CIDR for the VPC"
  default     = "10.0.0.0/24"
}

variable vpc_subnet_count {
  type        = number
  description = "positive integer count of how many public/private pairs of subnets are desired; if more than the number of available AZs, the number of AZs will override this"
  default     = 4
}

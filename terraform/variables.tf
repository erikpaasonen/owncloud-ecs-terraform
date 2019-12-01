locals {
  custom_domain_used               = tobool(length(var.r53_domain_name) > 0)
  custom_ssh_key_material_provided = tobool(length(var.ssh_public_key_material) > 0)
  mgmt_ip                          = length(var.mgmt_ip) == 0 ? "${data.http.my_public_ip.body}/32" : "${var.mgmt_ip}/32"
  owncloud_version                 = "10.3.0"
  private_key_material             = length(var.ssh_public_key_material) == 0 ? tls_private_key.owncloud[0].private_key_pem : file("~/.ssh/id_rsa")
}

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

variable r53_domain_name {
  type        = string
  description = "If you want your OwnCloud FQDN to utilize a domain hosted with AWS in Route 53, specify it here; otherwise, leave blank"
  default     = ""
}

variable rds_multi_az {
  type        = bool
  description = "Whether the RDS instance should span multiple availability zones; may impact cost"
  default     = false
}

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

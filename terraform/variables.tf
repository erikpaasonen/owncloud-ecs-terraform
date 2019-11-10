variable mgmt_ip {
  type        = string
  description = "IP address from which the OwnCloud instance will be managed"
}

variable region {
  type        = string
  description = "Name of the AWS region where these resources should go"
}

variable ssh_public_key_material {
  type        = string
  description = "The public key of an SSH key pair to be used to admin the EC2 instance0"
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

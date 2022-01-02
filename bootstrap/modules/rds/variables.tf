variable "namespaced_hostname" {
  type        = string
  description = "hostname base name including random pet name, for naming related resources"
}

variable "rds_engine_type" {
  type        = string
  description = "Valid RDS engine type value acceptable by the AWS RDS API."
}

variable "rds_multi_az" {
  type        = bool
  description = "Whether the RDS instance should span multiple availability zones; may impact cost"
}

variable "vpc" {
  type = object({
    id                 = string
    private_subnet_ids = list(string)
  })
  description = "Map of VPC ID and IDs of associated private subnets for use by the RDS instance"
}

variable "ecr_repo" {
  type = object({
    arn  = string
    name = string
  })
  description = "ARN and name of the ECR repo to which the built Docker image will be pushed"
}

variable "nextcloud_namespaced_hostname" {
  type        = string
  description = "prefix name to give to CodeBuild resources"
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket where the artifact is stored"
}

variable "parampath_mysql_passwd" {
  type        = string
  description = "Parameter Store path to the param containing the value of the MYSQL password"
}

variable "parampath_nc_admin_passwd" {
  type        = string
  description = "Parameter Store path to the param containing the value of the password set for the NextCloud Admin user account"
}

variable "parampath_obj_store_s3_secret" {
  type        = string
  description = "Parameter Store path to the param containing the value of the secret access key for the S3 backend data store"
}

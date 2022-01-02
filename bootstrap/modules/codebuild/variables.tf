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

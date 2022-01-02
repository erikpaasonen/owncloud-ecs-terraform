variable "github_pat" {
  type        = string
  description = "Personal Access Token from GitHub for retrieving source code for CodeBuild"
  sensitive   = true
}

variable "public_key_material" {
  type        = string
  description = "contents of the SSH public key for building trust into the AMI"
}

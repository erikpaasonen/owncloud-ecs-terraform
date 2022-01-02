variable "random_pet" {
  type = string
  description = "short phrase that is regenerated every time a new AMI is built to identify it"
}

variable "region" {
  type        = string
  description = "Name of the AWS region where these resources should go"
}

variable "ssh_pub_key_material" {
  type = string
  description = "contents of public key to be trusted by this server to login as ubuntu"
}


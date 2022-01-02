terraform {
  required_providers {
    aws = {
      version = ">= 3"
      source  = "hashicorp/aws"
    }

    http = {
      source = "hashicorp/http"
    }

    local = {
      source = "hashicorp/local"
    }

    null = {
      source = "hashicorp/null"
    }

    random = {
      source = "hashicorp/random"
    }

    tls = {
      source = "hashicorp/tls"
    }
  }

  required_version = ">= 1"
}

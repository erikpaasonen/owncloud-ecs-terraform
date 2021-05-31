terraform {
  required_providers {
    aws = {
      version = ">= 3.42.0"
      source  = "hashicorp/aws"
    }

    http = {
      source = "hashicorp/http"
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

  required_version = ">= 0.14.6"
}

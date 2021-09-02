provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
    managed_by_terraform = true
    }
  }
}

provider "http" {}

provider "null" {}

provider "random" {}

provider "tls" {}

provider "aws" {
  region = "us-west-2"

  # this is often useful for developer testing
  # profile = my_aws_cli_profile_name
}

provider "http" {
}

provider "local" {
}

provider "null" {
}

provider "random" {
}

provider "tls" {
}

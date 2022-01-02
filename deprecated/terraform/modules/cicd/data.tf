data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

data "aws_ami" "amlx2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

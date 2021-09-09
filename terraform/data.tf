
data "aws_ami" "selected" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*"]
  }

  filter {
    name   = "name"
    values = ["*20.04*"]
  }

  filter {
    name   = "name"
    values = ["*server*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_availability_zones" "current" {
  state = "available"
}

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

data "http" "my_public_ip" {
  # url = "https://ifconfig.me/ip"
  url = "https://api.ipify.org"
}

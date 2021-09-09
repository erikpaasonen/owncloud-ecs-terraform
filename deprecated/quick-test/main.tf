provider "aws" {
  profile = "iac"
  region  = "us-west-2"
}

data "aws_ami_ids" "ubuntu_20_04_lts" {
  owners = ["099720109477"] # Canonical

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

output "amis" {
  value = data.aws_ami_ids.ubuntu_20_04_lts.ids
}

output "how_many" {
  value = length(data.aws_ami_ids.ubuntu_20_04_lts.ids)
}

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

output "ami_info" {
  value = data.aws_ami.selected
}

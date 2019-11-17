data aws_ami ubuntu_18_04 {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

data aws_availability_zones current {
  state = "available"
}

data aws_vpc_endpoint_service s3 {
  service = "s3"
}

data http my_public_ip {
  url = "https://ifconfig.me/ip"
}

# data aws_ami_ids all_ubuntu_amis {
#   # owners = ["aws-marketplace"]

#   filter {
#     name   = "name"
#     values = ["*buntu*"]
#   }

#   filter {
#     name   = "name"
#     values = ["*18.04*"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

# data aws_ami image_details {
#   for_each = toset(data.aws_ami_ids.all_ubuntu_amis.ids)

#   owners = ["aws-marketplace"]

#   filter {
#     name   = "image-id"
#     values = [each.value]
#   }
# }

data aws_availability_zones current {
  state = "available"
}

data aws_ami owncloud_bitnami {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-owncloud-*"]
  }

  owners = ["aws-marketplace"]
}

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}



// data aws_ami_ids all_opencloud_amis {
//   owners = ["aws-marketplace"]

//   filter {
//     name   = "name"
//     values = ["*wn?loud*"]
//   }

//   filter {
//     name   = "architecture"
//     values = ["x86_64"]
//   }
// }

// data aws_ami image_details {
//   for_each = toset(data.aws_ami_ids.all_opencloud_amis.ids)

//   owners = ["aws-marketplace"]

//   filter {
//     name   = "image-id"
//     values = [each.value]
//   }
// }

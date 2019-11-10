output vpc_azs {
  value = module.vpc.azs
}

output vpc_private_subnets {
  value = zipmap(module.vpc.private_subnets, module.vpc.private_subnets_cidr_blocks)
}

output vpc_public_subnets {
  value = zipmap(module.vpc.public_subnets, module.vpc.public_subnets_cidr_blocks)
}

// output vpc_vpc_endpoint_s3_pl_id {
//   value = module.vpc.vpc_endpoint_s3_pl_id
// }

output vpc_id {
  value = module.vpc.vpc_id
}

output owncloud_ami_id {
  value = data.aws_ami.owncloud_bitnami.image_id
}

output owncloud_public_ip {
  value = aws_instance.owncloud_test.public_ip
}

output pet_name {
  value = random_pet.owncloud.id
}

output vpc_s3_endpoint_id {
  value = aws_vpc_endpoint.s3.id
}

output vpc_s3_endpoint_prefix_list_id {
  value = aws_vpc_endpoint.s3.prefix_list_id
}


// output image_ids {
//   value = data.aws_ami_ids.all_opencloud_amis.ids
// }

// output image_details {
//   value = {
//     block_device_mappings = data.aws_ami.owncloud_bitnami.block_device_mappings,
//     create_date           = data.aws_ami.owncloud_bitnami.creation_date,
//     desc                  = data.aws_ami.owncloud_bitnami.description,
//     id                    = data.aws_ami.owncloud_bitnami.image_id,
//     name                  = data.aws_ami.owncloud_bitnami.name,
//     owner_id              = data.aws_ami.owncloud_bitnami.owner_id,
//   }
// }

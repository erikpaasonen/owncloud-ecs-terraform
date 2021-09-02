output "kms_key_alias_name" {
  value = aws_kms_alias.nextcloud.name
}

output "management_ip" {
  value = split("/", local.mgmt_ip_cidr)[0]
}

output "pet_name" {
  value = random_pet.this.id
}

output "vpc_azs" {
  value = module.vpc.azs
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_private_subnets" {
  value = zipmap(module.vpc.private_subnets, module.vpc.private_subnets_cidr_blocks)
}

output "vpc_public_subnets" {
  value = zipmap(module.vpc.public_subnets, module.vpc.public_subnets_cidr_blocks)
}

output "vpc_s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}

output "vpc_s3_endpoint_prefix_list_id" {
  value = aws_vpc_endpoint.s3.prefix_list_id
}

# output vpc_vpc_endpoint_s3_pl_id {
#   value = module.vpc.vpc_endpoint_s3_pl_id
# }


# output how_many_image_ids {
#   value = length(data.aws_ami_ids.all_ubuntu_amis.ids)
# }

# output image_id_names {
#   value = sort([for img in data.aws_ami.image_details : {
#     owner = img.owner_id
#     name  = img.name
#   }])
# }

# output image_details {
#   value = {
#     block_device_mappings = data.aws_ami.ubuntu_18_04.block_device_mappings,
#     create_date           = data.aws_ami.ubuntu_18_04.creation_date,
#     desc                  = data.aws_ami.ubuntu_18_04.description,
#     id                    = data.aws_ami.ubuntu_18_04.image_id,
#     name                  = data.aws_ami.ubuntu_18_04.name,
#     owner_id              = data.aws_ami.ubuntu_18_04.owner_id,
#   }
# }

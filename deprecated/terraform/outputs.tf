output "kms_key_alias_name" {
  value = aws_kms_alias.nextcloud.name
}

output "management_ip" {
  value = split("/", local.mgmt_ip_cidr)[0]
}

output "instance_public_ip" {
  value = aws_instance.nextcloud.public_ip
}

output "pet_name" {
  value = random_pet.nextcloud.id
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

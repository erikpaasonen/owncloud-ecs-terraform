locals {
  vpc_subnet_count_validated = min(var.vpc_subnet_count, length(data.aws_availability_zones.current.zone_ids))
  vpc_cidr_base_bits         = tonumber(split("/", var.vpc_cidr)[1])

  # AWS only allows subnets to size /28, need space to split this in half for public/private
  # https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#VPC_Sizing
  cidr_newbits_max_range = 27 - local.vpc_cidr_base_bits
  eligible_cidr_bits     = [for i in range(local.cidr_newbits_max_range) : i if pow(2, i) >= local.vpc_subnet_count_validated]
  cidr_newbits           = local.eligible_cidr_bits[0]
  all_vpc_subnets        = [for i in range(local.vpc_subnet_count_validated) : cidrsubnet(var.vpc_cidr, local.cidr_newbits, i)]
  public_subnets         = [for cidr in local.all_vpc_subnets : cidrsubnet(cidr, 1, 0)]
  private_subnets        = [for cidr in local.all_vpc_subnets : cidrsubnet(cidr, 1, 1)]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # # AWS services endpoints - we'll attach these ourselves, thank you
  # enable_s3_endpoint            = true
  # enable_dynamodb_endpoint      = true
  # enable_ssm_endpoint           = true
  # enable_ssmmessages_endpoint   = true
  # enable_ec2_endpoint           = true
  # enable_ec2messages_endpoint   = true
  # enable_kms_endpoint           = true
  # enable_ecs_endpoint           = true
  # enable_ecs_telemetry_endpoint = true
  # enable_sqs_endpoint           = true
}

module "vpc" {
  # https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/outputs.tf
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs = slice(data.aws_availability_zones.current.names, 0, local.vpc_subnet_count_validated)

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = length(local.private_subnets)

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = element(module.vpc.private_route_table_ids, count.index)
}

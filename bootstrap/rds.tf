module "rds" {
  source = "./modules/rds"

  namespaced_hostname = "nextcloud-${random_pet.nextcloud.id}"
  rds_engine_type     = var.rds_engine_type
  rds_multi_az        = var.rds_multi_az
  vpc = {
    id                 = module.vpc.vpc_id
    private_subnet_ids = module.vpc.private_subnets
  }
}

resource "random_pet" "this" {
}

# this is unfortunately a pet, not cattle, so let's have fun with that fact
resource "random_pet" "nextcloud" {
  keepers = {
    ami_id       = data.aws_ami.selected.id
    vpc_id       = module.vpc.vpc_id
    ssh_key_hash = local.custom_ssh_key_material_provided ? sha1(var.ssh_public_key_material) : tls_private_key.nextcloud[0].public_key_fingerprint_md5
  }
}

resource "random_shuffle" "nextcloud_priv_subnet" {
  input        = module.vpc.public_subnets
  result_count = 1

  keepers = {
    random_pet = random_pet.nextcloud.id,
  }
}

resource "random_password" "ncadmin" {
  # the installation scripts force a password change on this user anyway
  # so this is a one-time login to complete setup
  lower   = true
  upper   = true
  number  = true
  special = false
  length  = 20

  keepers = {
    random_pet = random_pet.nextcloud.id,
  }
}

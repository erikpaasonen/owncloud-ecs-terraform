locals {
  nextcloud_version = "22.1.1" // https://nextcloud.com/changelog/
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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_pet.this.id}"
  public_key = local.public_key_material
}

# the intent is to use this script:
# https://github.com/nextcloud/vm/blob/master/nextcloud_install_production.sh
# must be run interactively as it asks a bunch of questions
# Terraform wouldn't be good at detecting drift from the scripted actions
# anyway... this is as far as Terraform _should_ go
resource "aws_instance" "nextcloud" {
  ami           = data.aws_ami.selected.image_id
  instance_type = "t3a.small"
  key_name      = aws_key_pair.deployer.key_name

  associate_public_ip_address = true

  subnet_id = random_shuffle.nextcloud_priv_subnet.result[0]

  vpc_security_group_ids = [
    aws_security_group.nextcloud_admin.id,
    aws_security_group.publish_443_to_internet.id,
    aws_security_group.egress.id,
    aws_security_group.to_s3.id,
  ]

  root_block_device {
    volume_size = 80
    delete_on_termination = true
  }

  user_data = <<USERDATA
#cloud-config

packages:
  - gzip
  - unzip
package_update: true
package_upgrade: true
  USERDATA

  tags = {
    Name = "nextcloud-ubuntu-${random_pet.nextcloud.id}"
  }
}

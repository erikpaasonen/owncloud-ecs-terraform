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

resource "aws_instance" "nextcloud" {
  ami           = data.aws_ami.selected.image_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  associate_public_ip_address = true

  subnet_id = random_shuffle.nextcloud_priv_subnet.result[0]

  vpc_security_group_ids = [
    aws_security_group.nextcloud_admin.id,
    aws_security_group.publish_443_to_internet.id,
    aws_security_group.egress.id,
    aws_security_group.to_s3.id,
  ]

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 40
    delete_on_termination = true
    encrypted             = true
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

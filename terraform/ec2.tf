locals {
  mgmt_ip = "${var.mgmt_ip}/32"
}

// this is unfortunately a pet, not cattle, so let's have fun with that fact
resource random_pet owncloud {
  keepers = {
    deploy_version     = "v0.0.1"
    deploy_description = "updates"
  }
}

resource random_shuffle owncloud_priv_subnet {
  input        = module.vpc.public_subnets
  result_count = 1

  keepers = {
    ami = random_pet.owncloud.keepers.deploy_version,
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.ssh_public_key_material
}

resource aws_instance owncloud_test {
  ami           = data.aws_ami.owncloud_bitnami.image_id
  instance_type = "t3.micro"
  subnet_id     = random_shuffle.owncloud_priv_subnet.result[0]
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [
    aws_security_group.owncloud_admin.id,
    aws_security_group.owncloud_service.id,
    aws_security_group.egress.id,
    aws_security_group.to_s3.id,
  ]

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "owncloud-bitnami-${random_pet.owncloud.id}"
  }
}

resource aws_security_group owncloud_admin {
  name_prefix = "owncloud-admin-"
  description = "${random_pet.owncloud.id} - allow initial setup and break-glass mgmt of OwnCloud instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip]
  }
}

resource aws_security_group owncloud_service {
  name_prefix = "owncloud-service-"
  description = "${random_pet.owncloud.id} - allow OwnCloud instance to serve OwnCloud service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip]
  }
}

resource aws_security_group egress {
  name_prefix = "egress-"
  description = "${random_pet.owncloud.id} - allows HTTP and HTTPS egress to the whole Internet"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_security_group to_s3 {
  name_prefix = "s3-"
  description = "${random_pet.owncloud.id} - allows HTTPS egress to the VPC S3 endpoint"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }
}

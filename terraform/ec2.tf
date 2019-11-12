locals {
  mgmt_ip          = "${var.mgmt_ip}/32"
  owncloud_version = "10.3.0"
}

resource random_shuffle owncloud_priv_subnet {
  input        = module.vpc.public_subnets
  result_count = 1

  keepers = {
    random_pet = random_pet.owncloud.id,
  }
}

resource aws_instance owncloud_test {
  ami           = data.aws_ami.ubuntu_18_04.image_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  associate_public_ip_address = true

  subnet_id = random_shuffle.owncloud_priv_subnet.result[0]

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

  # another delay tactic besides "sleep 30" is to hold up completion of instance creation until it responds to SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.owncloud.private_key_pem
    host        = aws_instance.owncloud_test.public_ip
  }

  # provisioner file {
  #   destination = "/etc/apache2/sites-available/owncloud.conf"
  #   source      = "./apache-owncloud.conf"
  # }

  # provisioner local-exec {
  #   command = "echo 'Waiting for user_data commands to complete...' && sleep 45"
  # }

  tags = {
    Name = "owncloud-fromscratch-ubuntu1804-${random_pet.owncloud.id}"
  }
}

resource null_resource install_owncloud {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.owncloud.private_key_pem
    host        = aws_instance.owncloud_test.public_ip
  }

  # provisioner remote-exec {
  #   inline = [
  #     "sudo apt-get update",
  #     "sudo apt install apache2",
  #     "sudo apt install gpg",
  #     "sudo apt install unzip",
  #   ]
  # }

  provisioner remote-exec {
    inline = [
      "sudo apt-get --assume-yes update",
      "sudo apt-get --assume-yes install apache2 gpg unzip",
      # "",
      # "",
      # "",
    ]
  }

  provisioner file {
    destination = "/tmp/owncloud.conf"
    source      = "./apache-owncloud.conf"
  }

  provisioner remote-exec {
    inline = [
      "sudo mv /tmp/owncloud.conf /etc/apache2/sites-available/owncloud.conf",
      "ln -s /etc/apache2/sites-available/owncloud.conf /etc/apache2/sites-enabled/owncloud.conf",
      "wget https://download.owncloud.org/owncloud.asc",
      "gpg --import owncloud.asc",
      "wget https://download.owncloud.org/community/owncloud-${local.owncloud_version}.zip",
      "wget https://download.owncloud.org/community/owncloud-${local.owncloud_version}.zip.sha256",
      "gpg --verify owncloud-${local.owncloud_version}.zip owncloud-${local.owncloud_version}.zip.sha256",
      "sha256sum -c owncloud-${local.owncloud_version}.zip.sha256 < owncloud-${local.owncloud_version}.zip",
      "unzip owncloud-${local.owncloud_version}.zip",
      "sudo cp -r owncloud /var/www",
      "sudo a2enmod rewrite",
      "sudo a2enmod headers",
      "sudo a2enmod env",
      "sudo a2enmod dir",
      "sudo a2enmod mime",
      "sudo a2enmod unique_id",
      "sudo systemctl restart apache2",
      # "",
      # "",
      # "",
    ]
  }

  depends_on = [
    aws_instance.owncloud_test,
  ]
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

locals {
  nextcloud_version = "22.1.1" // https://nextcloud.com/changelog/
}

# this is unfortunately a pet, not cattle, so let's have fun with that fact
resource "random_pet" "nextcloud" {
  keepers = {
    deploy_version     = "v0.0.1"
    deploy_description = "updates"
    ami_id             = data.aws_ami.amlx2.id
    vpc_id             = module.vpc.vpc_id
    ssh_key            = length(var.ssh_public_key_material) == 0 ? tls_private_key.nextcloud[0].public_key_fingerprint_md5 : sha1(var.ssh_public_key_material)
  }
}

resource "random_shuffle" "nextcloud_priv_subnet" {
  input        = module.vpc.public_subnets
  result_count = 1

  keepers = {
    random_pet = random_pet.nextcloud.id,
  }
}

resource "aws_instance" "nextcloud_test" {
  ami           = data.aws_ami.amlx2.image_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  associate_public_ip_address = true

  subnet_id = random_shuffle.nextcloud_priv_subnet.result[0]

  vpc_security_group_ids = [
    aws_security_group.nextcloud_admin.id,
    aws_security_group.nextcloud_service.id,
    aws_security_group.egress.id,
    aws_security_group.to_s3.id,
  ]

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true
  }

  # another delay tactic besides "sleep 30" is to hold up completion of instance creation until it responds to SSH
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = local.private_key_material
    host        = aws_instance.nextcloud_test.public_ip
  }

  tags = {
    Name = "nextcloud-amlx2-${random_pet.nextcloud.id}"
  }
}

resource "null_resource" "install_nextcloud" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = local.private_key_material
    host        = aws_instance.nextcloud_test.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras disable docker",
      "sudo amazon-linux-extras enable mariadb10.5 php8.0",
      "sudo yum clean metadata",
      "sudo yum install -y httpd mariadb php-cli php-pdo php-fpm php-mysqlnd",
      # "sudo a2enmod rewrite headers proxy proxy_fcgi setenvif env mime dir authz_core alias",
      # "sudo a2dismod mpm_prefork",
      # "echo \"# Turn off ServerTokens for both Apache and PHP\" >> /etc/apache2/apache2.conf",
      # "echo \"ServerSignature Off\" >> /etc/apache2/apache2.conf",
      # "echo \"ServerTokens Prod\" >> /etc/apache2/apache2.conf",
      "sudo systemctl enable httpd",
      "cat /etc/httpd/conf/httpd.conf",
      # "",
    ]
  }

  # provisioner "file" {
  #   destination = "/tmp/nextcloud.conf"
  #   source      = "./apache-nextcloud.conf"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "wget https://download.nextcloud.org/nextcloud.asc",
  #     # "gpg --import nextcloud.asc",
  #     "wget https://download.nextcloud.org/community/nextcloud-${local.nextcloud_version}.zip",
  #     "wget https://download.nextcloud.org/community/nextcloud-${local.nextcloud_version}.zip.sha256",
  #     "gpg --verify nextcloud.asc nextcloud-${local.nextcloud_version}.zip nextcloud-${local.nextcloud_version}.zip.sha256",
  #     "sha256sum -c nextcloud-${local.nextcloud_version}.zip.sha256 < nextcloud-${local.nextcloud_version}.zip",
  #     "unzip nextcloud-${local.nextcloud_version}.zip",
  #     "sudo cp -r nextcloud /var/www",
  #     "sudo a2enmod rewrite",
  #     "sudo a2enmod headers",
  #     "sudo a2enmod env",
  #     "sudo a2enmod dir",
  #     "sudo a2enmod mime",
  #     "sudo a2enmod unique_id",
  #     # "",
  #   ]
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo systemctl restart apache2",
  #     "sudo mv /tmp/nextcloud.conf /etc/apache2/sites-available/nextcloud.conf",
  #     "ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/nextcloud.conf",
  #     "sudo systemctl restart apache2",
  #     # "",
  #   ]
  # }

  depends_on = [
    aws_instance.nextcloud_test,
  ]
}

resource "aws_security_group" "nextcloud_admin" {
  name_prefix = "nextcloud-admin-"
  description = "${random_pet.nextcloud.id} - allow initial setup and break-glass mgmt of nextcloud instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip_cidr]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip_cidr]
  }
}

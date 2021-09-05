locals {
  nextcloud_version = "22.1.1" // https://nextcloud.com/changelog/
}

# this is unfortunately a pet, not cattle, so let's have fun with that fact
resource "random_pet" "nextcloud" {
  keepers = {
    ami_id  = data.aws_ami.ubuntu_20_04_lts.id
    vpc_id  = module.vpc.vpc_id
    ssh_key = length(var.ssh_public_key_material) == 0 ? tls_private_key.nextcloud[0].public_key_fingerprint_md5 : sha1(var.ssh_public_key_material)
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
  ami           = data.aws_ami.ubuntu_20_04_lts.image_id
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
    user        = "ubuntu"
    private_key = local.private_key_material
    host        = aws_instance.nextcloud_test.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo apt-get --assume-yes update",
      "sudo apt-cache gencaches",
      # "",
    ]
  }

  tags = {
    Name = "nextcloud-ubuntu-${random_pet.nextcloud.id}"
  }
}

# keep a separate null_resource with the provisioner stuff during troubleshooting
# these can be consolidated back into the aws_instance once everything is working
resource "null_resource" "install_nextcloud" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = local.private_key_material
    host        = aws_instance.nextcloud_test.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo installing generic stuff",
      "sudo apt-get --assume-yes install gpg",
      # 'sudo apt-get install unzip' is currently broken on this AMI
      "wget http://ubuntu.cs.utah.edu/ubuntu/pool/main/u/unzip/unzip_6.0-25ubuntu1_amd64.deb",
      "sudo dpkg -i unzip_6.0-25ubuntu1_amd64.deb",
    ]

  }

  provisioner "remote-exec" {
    inline = [
      "echo installing PHP 8...",
      "sudo add-apt-repository --yes ppa:ondrej/php",
      "sudo apt-get --assume-yes install php8.0 libapache2-mod-php8.0",
      # "",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo installing Apache 2.4...",
      "sudo apt-get --assume-yes install apache2 apache2-bin apache2-utils",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo installing MariaDB 10.5...",
      "sudo apt-get --assume-yes install mariadb-server mariadb-server-10.3 mariadb-common galera-3 mariadb-client-10.3 mariadb-server-core-10.3 socat libhtml-template-perl",
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

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
  - apt-transport-https
  - autoconf
  - automake
  - autopoint
  - autotools-dev
  - binutils
  - binutils-common
  - binutils-x86-64-linux-gnu
  - build-essential
  - cpp
  - cpp-9
  - debhelper
  - dh-autoreconf
  - dh-strip-nondeterminism
  - dpkg-dev
  - dwz
  - fakeroot
  - figlet
  - fontconfig-config
  - fonts-dejavu-core
  - g++
  - g++-9
  - gcc
  - gcc-9
  - gcc-9-base
  - gettext
  - gzip
  - intltool-debian
  - libalgorithm-diff-perl
  - libalgorithm-diff-xs-perl
  - libalgorithm-merge-perl
  - libapr1
  - libaprutil1
  - libaprutil1-dbd-sqlite3
  - libaprutil1-ldap
  - libarchive-cpio-perl
  - libarchive-zip-perl
  - libasan5
  - libatomic1
  - libavahi-client3
  - libavahi-common-data
  - libavahi-common3
  - libbinutils
  - libc-client2007e
  - libc-dev-bin
  - libc6-dev
  - libcc1-0
  - libcroco3
  - libcrypt-dev
  - libctf-nobfd0
  - libctf0
  - libcups2
  - libdebhelper-perl
  - libdpkg-perl
  - libfakeroot
  - libfile-fcntllock-perl
  - libfile-stripnondeterminism-perl
  - libfontconfig1
  - libgcc-9-dev
  - libgd3
  - libgomp1
  - libhiredis0.14
  - libisl22
  - libitm1
  - libjansson4
  - libjbig0
  - libjemalloc2
  - libjpeg-turbo8
  - libjpeg8
  - libldb2
  - libllvm10
  - liblsan0
  - libltdl-dev
  - liblua5.1-0
  - liblua5.2-0
  - libmail-sendmail-perl
  - libmpc3
  - libonig5
  - libpcre2-16-0
  - libpcre2-32-0
  - libpcre2-dev
  - libpcre2-posix2
  - libpq5
  - libquadmath0
  - libsensors-config
  - libsensors5
  - libsmbclient
  - libsmbclient-dev
  - libssl-dev
  - libstdc++-9-dev
  - libsub-override-perl
  - libsys-hostname-long-perl
  - libtalloc2
  - libtevent0
  - libtiff5
  - libtool
  - libtsan0
  - libubsan1
  - libwbclient0
  - libwebp6
  - libxpm4
  - libzip5
  - linux-libc-dev
  - lua-bitop
  - lua-cjson
  - m4
  - make
  - manpages-dev
  - mlock
  - net-tools
  - p7zip
  - p7zip-full
  - po-debconf
  - python3-talloc
  - redis-tools
  - samba-libs
  - shtool
  - ssl-cert
  - sysstat
  - unrar
package_update: true
package_upgrade: true
  USERDATA

  tags = {
    Name = "nextcloud-ubuntu-${random_pet.nextcloud.id}"
  }
}

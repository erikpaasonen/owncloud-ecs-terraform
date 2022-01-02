variable "random_pet" {
  type = string
  description = "short phrase that is regenerated every time a new AMI is built to identify it"
}

variable "region" {
  type        = string
  description = "Name of the AWS region where these resources should go"
}

variable "ssh_pub_key_material" {
  type = string
  description = "contents of public key to be trusted by this server to login as ubuntu"
}

source "amazon-ebs" "db" {
  ami_name = "nextcloud-db-${random_pet.this.id}"
  instance_type = "t3a.small"
  region = var.region
  ssh_username = "ubuntu"
  source_ami_filter {
    owners      = ["099720109477"] # Canonical
    most_recent = true

    filter {
      name   = "name"
      values = ["ubuntu/images/*"]
    }

    filter {
      name   = "name"
      values = ["*20.04*"]
    }

    filter {
      name   = "name"
      values = ["*server*"]
    }

    filter {
      name   = "root-device-type"
      values = ["ebs"]
    }

    filter {
      name   = "virtualization-type"
      values = ["hvm"]
    }

    filter {
      name   = "architecture"
      values = ["x86_64"]
    }
  }
}

build {
  sources = ["source.amazon-ebs.db"]

  provisioner "file" {
    # record the public key material from the generated key pair
    # into the instance
    source_content = tls_private_key.nextcloud.public_key_pem
    destination = "/tmp/tf-packer.pub"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get --assume-yes update",
      "",
    ]
  }
}

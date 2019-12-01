resource aws_security_group owncloud_rds_access {
  name        = "owncloud-${random_pet.this.id}-db-access-sg"
  description = "Attach this SG to resources to allow them to access RDS"
  vpc_id      = module.vpc.vpc_id

  tags {
    Name = "owncloud-${random_pet.this.id}-db-access-sg"
  }
}

resource aws_security_group rds_enablement {
  name_prefix = "owncloud-${random_pet.this.id}-rds-sg-"
  description = "resource-specific SG attached ONLY to the RDS instance; NOT for attaching to things that need to access RDS"
  vpc_id      = module.vpc.vpc_id

  tags {
    Name = "owncloud-${random_pet.this.id}-rds-sg"
  }

  # allow RDS instances to communicate with each other
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # allow traffic for TCP 3306
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.owncloud_rds_access.id}"]
  }
}

resource aws_security_group owncloud_admin {
  count = 0

  name_prefix = "owncloud-admin-"
  description = "${random_pet.this.id} - allow initial setup and break-glass mgmt of OwnCloud instance"
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
  description = "${random_pet.this.id} - allow OwnCloud instance to serve OwnCloud service"
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
  description = "${random_pet.this.id} - allows HTTP and HTTPS egress to the whole Internet"
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
  description = "${random_pet.this.id} - allows HTTPS egress to the VPC S3 endpoint"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
  }
}

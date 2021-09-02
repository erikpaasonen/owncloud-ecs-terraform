resource "aws_security_group" "nextcloud_service" {
  name_prefix = "nextcloud-service-"
  description = "${random_pet.this.id} - allow nextcloud instance to serve nextcloud service; restricted to management IP for testing"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.mgmt_ip_cidr]
  }
}

resource "aws_security_group" "egress" {
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

resource "aws_security_group" "to_s3" {
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

resource "aws_security_group" "nextcloud_rds_access" {
  name        = "${var.namespaced_hostname}-db-access"
  description = "Attach this SG to resources to allow them to access RDS"
  vpc_id      = var.vpc.id
}

resource "aws_security_group" "rds_enablement" {
  name_prefix = "${var.namespaced_hostname}-rds-"
  description = "resource-specific SG attached ONLY to the RDS instance; NOT for attaching to things that need to access RDS"
  vpc_id      = var.vpc.id

  # allow traffic for TCP 3306 to any ENI which has the proper access SG attached
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.nextcloud_rds_access.id}"]
  }

  # allow RDS instances to communicate openly with each other
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # allow RDS instances to communicate openly with each other
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}

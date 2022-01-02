resource "aws_cloudwatch_log_group" "codebuild" {
  name_prefix       = "${var.nextcloud_namespaced_hostname}-"
  retention_in_days = "3"
}

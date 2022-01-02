resource "aws_kms_key" "nextcloud" {
}

resource "aws_kms_alias" "nextcloud" {
  name_prefix   = "alias/${local.nextcloud_namespaced_hostname}-"
  target_key_id = aws_kms_key.nextcloud.key_id
}

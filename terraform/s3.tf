# resource aws_s3_bucket owncloud_objectstore {
#   bucket_prefix = "${local.owncloud_namespaced_hostname}-objectstore-"

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         kms_master_key_id = aws_kms_key.owncloud.arn
#         sse_algorithm     = "aws:kms"
#       }
#     }
#   }

#   lifecycle_rule {
#     id      = "objectstore"
#     enabled = true

#     tags = {
#       "rule"      = "objectstore"
#       "autoclean" = "false"
#     }

#     transition {
#       days          = 1
#       storage_class = "STANDARD_IA" # or "ONEZONE_IA"
#     }

#     transition {
#       days          = 2
#       storage_class = "GLACIER"
#     }

#     # expiration {
#     #   days = 90
#     # }
#   }
# }

# resource aws_s3_bucket_policy owncloud_objectstore {
#   bucket = aws_s3_bucket.owncloud_objectstore.id
#   policy = data.aws_iam_policy_document.owncloud_objectstore.json
# }

# data aws_iam_policy_document owncloud_objectstore {
#   statement {
#     sid = "HTTPSOnly"

#     effect = "Deny"

#     actions = [
#       "s3:PutObject",
#     ]

#     resources = [
#       aws_s3_bucket.owncloud_objectstore.arn,
#     ]

#     condition {
#       test     = "Bool"
#       variable = "aws:SecureTransport"
#       values   = ["false"]
#     }
#   }

#   statement {
#     sid = "SSE"

#     effect = "Deny"

#     actions = [
#       "s3:PutObject",
#     ]

#     resources = [
#       aws_s3_bucket.owncloud_objectstore.arn,
#     ]

#     condition {
#       test     = "StringNotEquals"
#       variable = "s3:x-amz-server-side-encryption"
#       values   = ["AES256"]
#     }
#   }
# }

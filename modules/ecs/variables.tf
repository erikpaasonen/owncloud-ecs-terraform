locals {
  namespaced_redis_hostname = "${var.namespaced_hostname}-redis"
}

variable "namespaced_hostname" {
  type = string
  description = "hostname base name including random pet name, for naming related resources"
}

# onefs variables

variable "region" {
  default = "us-east-1"
}

variable "iam_instance_profile" {
}

variable "network_id" {
}

variable "id" {
}

variable "name" {
}

variable "nodes" {
  default = null
}

variable "http_tokens" {
  default = null
}

variable "availability_zone" {}

variable "internal_subnet_id" {
}

variable "external_subnet_id" {}

variable "enable_mgmt" {
  default = null
}

variable "mgmt_subnet_id" {
  default = null
}

variable "contiguous_ips" {
  default     = false
  description = "Assign contiguous IPs to external and (if enabled) management NICs"
}

variable "gateway_hostnum" {
  default = 1
}

variable "smartconnect_hostnum" {
  default     = 4
  description = "Only applicable when contiguous_ips is true"
}

variable "first_external_node_hostnum" {
  default     = 5
  description = "Only applicable when contiguous_ips is true"
}

variable "first_internal_node_hostnum" {
  default = 5
}

variable "security_group_external_id" {
}

variable "security_group_mgmt_id" {
  default = null
}

variable "first_mgmt_node_hostnum" {
  default     = 5
  description = "Only applicable when contiguous_ips is true"
}

variable "credentials_hashed" {
  type    = bool
  default = true
}

variable "root_password" {
  sensitive = true
}

variable "admin_password" {
  sensitive = true
}

variable "image_id" {
  default = null
}

variable "dns_servers" {
  default = ["169.254.169.253"]
}

variable "dns_domains" {
  default = ["us-east-1.compute.internal"]
}

variable "smartconnect_zone" {
  type        = string
  description = "FQDN to use as the DNS zone for SmartConnect"
}

variable "timezone" {
  type    = string
  default = "Greenwich Mean Time"
}

variable "resource_tags" {
  type = map(string)
  default = {
  }
}

variable "instance_type" {
  default = null
}

variable "os_disk_type" {
  default = null
}

# Input validation for this variable is done as precondition
# within node.tf
variable "data_disk_type" {
  default = null
  type    = string
}

variable "data_disk_size" {
  default = null
}

variable "data_disks_per_node" {
  default = null
}

variable "data_disk_iops" {
  default = null
}

variable "data_disk_throughput" {
  default = null
}

# Deprecated as part of OCM-4282
variable "linear_journal" {
  type    = bool
  default = null
}

variable "validate_volume_type" {
  type    = bool
  default = null
}

variable "placement_group_strategy" {
  default = null
}

variable "partition_count" {
  default = null
}

variable "onefs_build" {
  type        = string
  description = "Get the ami_id from the build_no"
  default     = null
}

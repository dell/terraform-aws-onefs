/*

	Copyright (c) 2023 Dell, Inc or its subsidiaries.
	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

variable "admin_password" {
  sensitive = true
}
variable "availability_zone" {}
variable "contiguous_ips" {
  default = false
}
variable "credentials_hashed" {
  type    = bool
  default = true
}
variable "data_disk_iops" {
  default = null
}
variable "data_disk_size" {
  default = null
}
variable "data_disks_per_node" {
  default = null
}
variable "data_disk_throughput" {
  default = null
}
variable "data_disk_type" {
  default = null
  type    = string
}
variable "dns_domains" {
  default = ["us-east-1.compute.internal"]
}
variable "dns_servers" {
  default = ["169.254.169.253"]
}
variable "enable_mgmt" {
  default = null
}
variable "external_subnet_id" {}
variable "first_external_node_hostnum" {
  default = 5
}
variable "first_internal_node_hostnum" {
  default = 5
}
variable "first_mgmt_node_hostnum" {
  default = 5
}
variable "gateway_hostnum" {
  default = 1
}
variable "http_tokens" {
  default = null
}
variable "iam_instance_profile" {}
variable "id" {}
variable "image_id" {
  default = null
}
variable "instance_type" {
  default = null
}
variable "internal_sg_id" {}
variable "internal_subnet_id" {}
variable "mgmt_subnet_id" {
  default = null
}
variable "name" {}
variable "network_id" {}
variable "nodes" {
  default = null
}
#variable "onefs_build" {}
variable "os_disk_type" {
  default = null
}
variable "partition_count" {
  default = null
}
variable "placement_group_strategy" {
  default = null
}
variable "region" {
  default = "us-east-1"
}
variable "resource_tags" {
  type = map(string)
  default = {
  }
}
variable "root_password" {
  sensitive = true
}
variable "security_group_external_id" {}
variable "security_group_mgmt_id" {
  default = null
}
variable "skip_credentials_validation" {
  default = false
}
variable "skip_requesting_account_id" {
  default = false
}
variable "skip_metadata_api_check" {
  default = false
}
variable "smartconnect_hostnum" {
  default = 4
}
variable "smartconnect_zone" {
  type = string
}
variable "timezone" {
  type    = string
  default = null
}
variable "validate_volume_type" {
  type    = bool
  default = null
}

# Deprecated as part of OCM-4282
variable "linear_journal" {
  type    = bool
  default = null
}

# Datasource to vars
variable "internal_subnet_cidr_block" {}
variable "external_subnet_cidr_block" {}
variable "mgmt_subnet_cidr_block" {}
variable "hashed_admin_password" {}
variable "hashed_root_password" {}


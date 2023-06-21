/*

	Copyright (c) 2023 Dell, Inc or its subsidiaries.
	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

# onefs variables

variable "region" {
  default     = "us-east-1"
  description = "AWS default region for creating resources"
}

variable "iam_instance_profile" {
  description = "AWS IAM instance profile for attaching to onefs nodes(EC2 VMs)"
}

variable "network_id" {
  description = "VPC ID, where the cluster resources will get created"
}

variable "id" {
  description = "Cluster ID, an unique identifier for onefs cluster"
}

variable "name" {
  description = "Name of cluster"
}

variable "nodes" {
  default     = null
  description = "Number of nodes in the cluster"
}

variable "http_tokens" {
  default     = null
  description = "Set http_tokens to Optional or Required to modify instance metadata. Default is Required"
}

variable "availability_zone" {
  description = "Availabity zone to create onefs cluster and its resources"
}

variable "internal_subnet_id" {
  description = "ID of internal subnet, internal subnet should be reserved exclusively for use by a single OneFS and must contain enough free IP addresses to assign 1 IP for each instance in the cluster"
}

variable "external_subnet_id" {
  description = "ID of external subnet, external subnet must have at least 1 free IP address for each node in the OneFS deployment being planned. This subnet can be shared with other clients"
}

variable "enable_mgmt" {
  default     = null
  description = "Boolean variable, if true management subnet is created for cluster"
}

variable "mgmt_subnet_id" {
  default     = null
  description = "ID of management subnet, this is required if enable_mgmt is true"
}

variable "contiguous_ips" {
  default     = false
  description = "Assign contiguous IPs to external and (if enabled) management NICs"
}

variable "gateway_hostnum" {
  default     = 1
  description = "The host number of the gateway in a subnet"
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
  default     = 5
  description = "Host number for the first internal node"
}

variable "security_group_external_id" {
  description = "ID of external security group, required to apply to the external interfaces in the cluster"
}

variable "security_group_mgmt_id" {
  default     = null
  description = "ID of management security group, required to apply to the management interfaces in the cluster"
}

variable "first_mgmt_node_hostnum" {
  default     = 5
  description = "Only applicable when contiguous_ips is true"
}

variable "credentials_hashed" {
  type        = bool
  default     = true
  description = "The password hash setting, password is hashed using openssl if true"
}

variable "root_password" {
  sensitive   = true
  description = "The root password for the OneFS cluster"
}

variable "admin_password" {
  sensitive   = true
  description = "The admin password for the OneFS cluster"
}

variable "image_id" {
  default     = null
  description = "AMI ID for creating OneFS cluster nodes"
}

variable "dns_servers" {
  default     = ["169.254.169.253"]
  description = "DNS server to route traffic"
}

variable "dns_domains" {
  default     = ["us-east-1.compute.internal"]
  description = "DNS domain to route traffic"
}

variable "smartconnect_zone" {
  type        = string
  description = "FQDN to use as the DNS zone for SmartConnect"
}

variable "timezone" {
  type        = string
  default     = null
  description = "Time zone for creating OneFS cluster resources in AWS"
}

variable "resource_tags" {
  type = map(string)
  default = {
  }
  description = "Tags to identify the OneFS cluster resources in AWS"
}

variable "instance_type" {
  default     = null
  description = "Instance type determines the number of CPU cores, the amount of memory, the storage capacity, and the networking capabilities of instance(OneFS nodes)"
}

variable "os_disk_type" {
  default     = null
  description = "Disk type of root block device, if null it takes gp3"
}

# Input validation for this variable is done as precondition
# within node.tf
variable "data_disk_type" {
  default     = null
  type        = string
  description = "Volume type for EBS volume, if null it takes gp3"
}

variable "data_disk_size" {
  default     = null
  description = "Size of the volume, if null it takes 16"
}

variable "data_disks_per_node" {
  default     = null
  description = "Number of EBS voulmes per node"
}

variable "data_disk_iops" {
  default     = null
  description = "IOPS value for EBS volume"
}

variable "data_disk_throughput" {
  default     = null
  description = "Throughput for EBS volume"
}

# Deprecated as part of OCM-4282
variable "linear_journal" {
  type        = bool
  default     = null
  description = "Boolean var to set Linear journal value to true or false"
}

variable "validate_volume_type" {
  type        = bool
  default     = null
  description = "Boolean var to validate volume type"
}

variable "placement_group_strategy" {
  default     = null
  description = "The placement strategy for aws placement group. Can be cluster, partition or spread. If left null value will be spread"
}

variable "partition_count" {
  default     = null
  description = "The number of partitions to create in the placement group. Can only be specified when the placement_group_strategy is set to partition. Valid values are 1 - 7"
}

variable "onefs_build" {
  type        = string
  default     = null
  description = "Get the ami_id from the build_no"
}

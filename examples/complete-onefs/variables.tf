/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

variable "nodes" {
  default = null
}

variable "placement_group_strategy" {
  default = null
}

variable "partition_count" {
  default = null
}


variable "data_disk_type" {
  default = "gp3"
  type    = string
}

variable "data_disk_iops" {
  default = null
}

variable "data_disk_throughput" {
  default = null
}

variable "onefs_build" {
  default = null
}

variable "image_id" {
  default = null
}

variable "external_cidr_block" {
  default = null
}

variable "internal_cidr_block" {
  default = null
}

variable "mgmt_cidr_block" {
  default = null
}

variable "external_subnet_id" {
  description = "Subnet ID of the AWS Subnet where the external network related resources will be created"
}

variable "internal_subnet_id" {
  description = "Subnet ID of the AWS Subnet where the internal network related resources will be created"
}

variable "mgmt_subnet_id" {
  default = null
}

variable "enable_mgmt" {
  default = null
}

variable "contiguous_ips" {
  default     = null
  description = "Assign contiguous IPs to external and (if enabled) management NICs"
}

variable "vpc_id" {
  default = null
}

variable "resource_tags" {
  type = map(any)
  default = {
  }
}

variable "credentials_hashed" {
  type        = bool
  description = "Property to indicate if the password is hashed using openssl passwd, password is hashed if set to true"
}

variable "default_hashed_password" {
  type        = string
  sensitive   = true
  description = "The default hashed password, using this will set the same hashed password to both root and admin users. Applicable only when credentials_hashed is set as true"
  default     = null
}

variable "default_plain_text_password" {
  type        = string
  sensitive   = true
  description = "The default plain-text password, using this will set the same plain-text password to both root and admin users.. Applicable only when credentials_hashed is set as false"
  default     = null
}

variable "hashed_admin_passphrase" {
  sensitive   = true
  default     = null
  description = "The admin user's hashed password for the OneFS cluster. Applicable only when credentials_hashed is set as true"
}

variable "hashed_root_passphrase" {
  sensitive   = true
  default     = null
  description = "The root user's hashed password for the OneFS cluster. Applicable only when credentials_hashed is set as true"
}

variable "admin_password" {
  sensitive   = true
  default     = null
  description = "The admin user's password for the OneFS cluster in plain text. Applicable only when credentials_hashed is set as false"
}

variable "root_password" {
  sensitive   = true
  default     = null
  description = "The root user's password for the OneFS cluster in plain text. Applicable only when credentials_hashed is set as false"
}

variable "cluster_id" {
  default     = null
  description = "Cluster ID, an unique identifier for onefs cluster. "
}

variable "cluster_name" {
  default     = null
  description = "The name of the PowerScale Cluster. Cluster names must begin with a letter and can contain only numbers, letters, and hyphens. If the cluster is joined to an Active Directory domain, the cluster name must be 11 characters or fewer."
}

variable "external_sg_id" {
  default     = null
  description = "The external security group ID"
}

variable "mgmt_sg_id" {
  default = null
}

variable "internal_sg_id" {
  default     = null
  description = "The internal security group ID"
}

variable "instance_type" {
  default = null
}

variable "validate_instance_type" {
  type        = bool
  default     = null
  description = "Boolean variable to validate EC2 instance type"
}

variable "availability_zone" {
  default = "us-east-1b"
}

variable "region" {
  default = "us-east-1"
}

variable "iam_instance_profile" {
  default = null
}

variable "os_disk_type" {
  default = null
}

variable "validate_volume_type" {
  type    = bool
  default = true
}

variable "data_disk_size" {
  default     = null
  description = "Size of the volume, if null it takes 16"
}

variable "data_disks_per_node" {
  default     = null
  description = "Size of the volume, if null it takes 16"
}

variable "validate_data_disks_count" {
  default = null
}

variable "validate_nodes_count" {
  type    = bool
  default = null
}

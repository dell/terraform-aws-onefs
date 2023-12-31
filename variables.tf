/*

	Copyright (c) 2023 Dell, Inc or its subsidiaries.
	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

# onefs variables

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS default region for creating resources"
}

variable "iam_instance_profile" {
  type        = string
  description = "AWS IAM instance profile for attaching to onefs nodes(EC2 VMs)"
}

variable "id" {
  type        = string
  description = "Cluster ID, an unique identifier for onefs cluster"
}

variable "name" {
  type        = string
  description = "The name of the PowerScale Cluster. Cluster names must begin with a letter and can contain only numbers, letters, and hyphens. If the cluster is joined to an Active Directory domain, the cluster name must be 11 characters or fewer."
}

variable "nodes" {
  default     = null
  description = "Number of nodes in the cluster"
  type        = number
}

variable "http_tokens" {
  default     = "required"
  type        = string
  description = "Set http_tokens to \"optional\" or \"required\" to modify instance metadata. Default is \"required\""
  validation {
    condition = var.http_tokens == null ? true : contains(
      ["optional", "required"],
      var.http_tokens
    )
    error_message = join("", [
      "The value provided for \"http_tokens\" input variable: \"${var.http_tokens}\" is invalid. ",
      "The allowed values are: \"optional\", \"required\"."
    ])
  }
}

variable "availability_zone" {
  type        = string
  description = "Availabity zone to create onefs cluster and its resources"
}

variable "internal_subnet_id" {
  type        = string
  description = "ID of internal subnet, internal subnet should be reserved exclusively for use by a single OneFS and must contain enough free IP addresses to assign 1 IP for each instance in the cluster"
}

variable "external_subnet_id" {
  type        = string
  description = "ID of external subnet, external subnet must have at least 1 free IP address for each node in the OneFS deployment being planned. This subnet can be shared with other clients"
}

variable "enable_mgmt" {
  default     = null
  type        = bool
  description = "Boolean variable, if true management subnet is created for cluster"
}

variable "mgmt_subnet_id" {
  default     = null
  type        = string
  description = "ID of management subnet, this is required if enable_mgmt is true"
}

variable "contiguous_ips" {
  default     = false
  type        = bool
  description = "Assign contiguous IPs to external and (if enabled) management NICs"
}

variable "first_external_node_hostnum" {
  default     = 5
  type        = number
  description = "Only applicable when contiguous_ips is true"
}

variable "first_internal_node_hostnum" {
  default     = 5
  type        = number
  description = "Host number for the first internal node"
}

variable "security_group_external_id" {
  type        = string
  description = "ID of external security group, required to apply to the external interfaces in the cluster"
}

variable "security_group_mgmt_id" {
  default     = null
  type        = string
  description = "ID of management security group, required to apply to the management interfaces in the cluster"
}

variable "first_mgmt_node_hostnum" {
  default     = 5
  type        = number
  description = "Only applicable when contiguous_ips is true"
}

variable "credentials_hashed" {
  type        = bool
  default     = true
  description = "The password hash setting, password is hashed using openssl if true"
}

variable "root_password" {
  sensitive   = true
  type        = string
  description = "The root password for the OneFS cluster"
  default     = null
}

variable "admin_password" {
  sensitive   = true
  type        = string
  description = "The admin password for the OneFS cluster"
  default     = null
}

variable "image_id" {
  default     = null
  type        = string
  description = "AMI ID for creating OneFS cluster nodes"
}

variable "dns_servers" {
  default     = ["169.254.169.253"]
  type        = list(string)
  description = "DNS server to route traffic"
  validation {
    condition     = alltrue([for each_address in var.dns_servers : can(cidrhost("${each_address}/32", 0))])
    error_message = "For the dns_servers value the valid input is a list of IP addresses."
  }
}

variable "dns_domains" {
  default     = null
  type        = list(string)
  description = "DNS domain to route traffic"
  validation {
    condition     = var.dns_domains == null ? true : alltrue([for each_domain in var.dns_domains : can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?:\\.[a-zA-Z]{2,})+$", each_domain))])
    error_message = "For the dns_domains value the valid input is a list of domain names."
  }
}

variable "timezone" {
  type        = string
  default     = null
  description = "Time zone of the OneFS cluster"
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
  type        = string
}

variable "os_disk_type" {
  default     = null
  description = "Disk type of root block device, if null it takes gp3"
  type        = string
}

# Input validation for this variable is done as precondition
# within node.tf
variable "data_disk_type" {
  default     = null
  type        = string
  description = "Volume type for EBS volume, if null it takes gp3"
}

variable "data_disk_size" {
  type        = number
  default     = null
  description = "Size of the additional EBS volume"
}
variable "validate_data_disk_size" {
  type        = bool
  default     = null
  description = "Boolean variable to enable/disable EBS volume size validation"
}
variable "data_disks_per_node" {
  default     = null
  type        = number
  description = "Number of EBS volumes per node"
}

variable "validate_data_disks_count" {
  default     = null
  description = <<EOT
    Boolean variable to enable/disable validation of
    the number of data disks which are attached to each node  
  EOT
}

variable "data_disk_iops" {
  default     = null
  type        = number
  description = "IOPS value for EBS volume"
}

variable "data_disk_throughput" {
  default     = null
  type        = number
  description = "Throughput for EBS volume"
}

variable "validate_instance_type" {
  type        = bool
  default     = null
  description = "Boolean variable to validate EC2 instance type"
}

variable "validate_os_disk_type" {
  type        = bool
  default     = null
  description = "Boolean variable to validate OS Disk type"
}

variable "validate_volume_type" {
  type        = bool
  default     = null
  description = "Boolean variable to validate volume type. It is strongly recommended to not update this field for production use."
}

variable "validate_nodes_count" {
  type        = bool
  default     = null
  description = "Boolean variable to validate nodes count. It is strongly recommended to not update this field for production use."
}

variable "placement_group_strategy" {
  default     = null
  type        = string
  description = "The placement strategy for aws placement group. Can be cluster, partition or spread. If left null value will be spread"
}

variable "validate_placement_group_strategy" {
  type        = bool
  default     = null
  description = "Boolean variable to enable/disable validation of EC2 placement group strategy."
}

variable "partition_count" {
  default     = null
  type        = number
  description = "The number of partitions to create in the placement group. Can only be specified when the placement_group_strategy is set to partition. Valid values are 1 - 7"
}

#
#  INTERNAL Networking Inteface Security Group & Rules
#
variable "internal_sg_id" {
  type        = string
  description = "Security group ID to be attached to the internal network interfaces"
}

variable "hashed_root_passphrase" {
  sensitive   = true
  type        = string
  default     = null
  description = "hashed root passphrase to create the onefs cluster"
}

variable "hashed_admin_passphrase" {
  sensitive   = true
  type        = string
  default     = null
  description = "hashed admin passphrase to create the onefs cluster"
}

/*

	Copyright (c) 2023 Dell, Inc or its subsidiaries.
	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

variable "nodes" {
  type        = number
  description = "Number of nodes."
}

variable "name" {
  type        = string
  description = "Name of cluster."
}

variable "timezone" {
  type        = string
  description = "Timezone."
  default     = null
}

variable "enable_mgmt" {
  type        = bool
  description = "True to enable the management interfaces."
  default     = false
}

variable "data_disk_type" {
  type        = string
  description = "Disk type of data volumes."
}

variable "internal_ips" {
  type        = list(string)
  description = "List of internal interface IPs in order starting with node 0."
}

variable "external_ips" {
  type        = list(string)
  description = "List of external interface IPs in order starting with node 0."
}

variable "mgmt_ips" {
  type        = list(string)
  description = "List of management interface IPs in order starting with node 0 or null if not configured."
  default     = null
}

variable "internal_network_mask" {
  type        = string
  description = "Network mask for internal subnet in dotted-quad notation."
}

variable "external_network_mask" {
  type        = string
  description = "Network mask for external subnet in dotted-quad notation."
}

variable "mgmt_network_mask" {
  type        = string
  description = "Network mask for management subnet in dotted-quad notation or null if not configured."
  default     = null
}

variable "external_gateway_ip" {
  type        = string
  description = "Default gateway IP for external subnet."
}

variable "mgmt_gateway_ip" {
  type        = string
  description = "Default gateway IP for management subnet or null if not configured."
  default     = null
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers."
}

variable "dns_domains" {
  type        = list(string)
  description = "List of DNS search domains."
}

variable "credentials_hashed" {
  type        = bool
  description = "If true, hashed password variables are used instead of plaintext."
}

variable "hashed_root_password" {
  type        = string
  description = "The hashed root password."
  default     = null
}

variable "hashed_admin_password" {
  type        = string
  description = "The hashed admin password."
  default     = null
}

variable "root_password" {
  type        = string
  description = "Plaintext root password."
  default     = null
}

variable "admin_password" {
  type        = string
  description = "Plaintext admin password."
  default     = null
}


locals {
  serial_numbers = [for node_number in range(var.nodes) : "SV200-930073-${format("%04d", node_number)}"]
  timezone       = var.timezone == null ? "Greenwich Mean Time" : var.timezone
  devices = var.enable_mgmt ? [for index in range(var.nodes) : {
    "serial_number" : local.serial_numbers[index]
    "int-a" : var.internal_ips[index]
    "ext-1" : var.external_ips[index]
    "mgmt-1" : var.mgmt_ips[index]
    }] : [for index in range(var.nodes) : {
    "serial_number" : local.serial_numbers[index]
    "int-a" : var.internal_ips[index]
    "ext-1" : var.external_ips[index]
  }]
  machineid = [for node_number in range(var.nodes) : jsonencode(jsondecode(
    templatefile("${path.module}/machineid.tftemplate.json", {
      node_number           = node_number
      name                  = var.name
      timezone              = local.timezone
      serial_numbers        = local.serial_numbers
      data_disk_type        = var.data_disk_type
      devices               = local.devices
      enable_mgmt           = var.enable_mgmt
      internal_ips          = var.internal_ips
      external_ips          = var.external_ips
      mgmt_ips              = var.mgmt_ips
      internal_network_mask = var.internal_network_mask
      external_network_mask = var.external_network_mask
      mgmt_network_mask     = var.mgmt_network_mask
      external_gateway_ip   = var.external_gateway_ip
      mgmt_gateway_ip       = var.mgmt_gateway_ip
      dns_servers           = var.dns_servers
      dns_domains           = var.dns_domains
      credentials_hashed    = var.credentials_hashed
      hashed_root_password  = var.hashed_root_password
      hashed_admin_password = var.hashed_admin_password
      root_password         = var.root_password
      admin_password        = var.admin_password
    })
  ))]
}

output "machineid" {
  value       = local.machineid
  description = "The machine ID of the Onefs node"
}

output "serial_numbers" {
  value = local.serial_numbers
}

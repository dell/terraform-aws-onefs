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

variable "instance_type" {
  type        = string
  description = "EC2 instance type, used to derive hal_dram_size."
}


locals {
  serial_numbers = [for node_number in range(var.nodes) : "SV200-930073-${format("%04d", node_number)}"]

  # Memory size in bytes per instance type.  PSI uses hal_dram_size to
  # derive a deterministic model string so that SmartPools groups nodes
  # consistently, regardless of hw.realmem variance between instances
  # of the same type.  See PSCALE-165033 / cee9e96b.
  instance_memory_bytes = {
    "m5dn.8xlarge"   = 137438953472 # 128 GiB
    "m5dn.12xlarge"  = 206158430208 # 192 GiB
    "m5dn.16xlarge"  = 274877906944 # 256 GiB
    "m5dn.24xlarge"  = 412316860416 # 384 GiB
    "m5d.24xlarge"   = 412316860416 # 384 GiB
    "m6idn.8xlarge"  = 137438953472 # 128 GiB
    "m6idn.12xlarge" = 206158430208 # 192 GiB
    "m6idn.16xlarge" = 274877906944 # 256 GiB
    "m6idn.24xlarge" = 412316860416 # 384 GiB
    "m8idn.8xlarge"  = 137438953472 # 128 GiB
    "m8idn.12xlarge" = 206158430208 # 192 GiB
    "m8idn.16xlarge" = 274877906944 # 256 GiB
    "m8idn.24xlarge" = 412316860416 # 384 GiB
    "m8id.12xlarge"  = 206158430208 # 192 GiB
    "m8id.16xlarge"  = 274877906944 # 256 GiB
    "m8id.24xlarge"  = 412316860416 # 384 GiB
    "i7i.12xlarge"   = 412316860416 # 384 GiB
    "i7i.16xlarge"   = 549755813888 # 512 GiB
    "i7i.24xlarge"   = 824633720832 # 768 GiB
    "i7ie.12xlarge"  = 412316860416 # 384 GiB
    "i7ie.18xlarge"  = 618475290624 # 576 GiB
    "i7ie.24xlarge"  = 824633720832 # 768 GiB
  }
  hal_dram_size = try(tostring(local.instance_memory_bytes[var.instance_type]), null)
  timezone      = var.timezone == null ? "Greenwich Mean Time" : var.timezone
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
      hal_dram_size         = local.hal_dram_size
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

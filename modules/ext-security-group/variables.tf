/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

variable "cluster_id" {
  default     = null
  description = "The cluster Id"
}

variable "resource_tags" {
  type = map(string)
  default = {
  }
  description = "The Tags to be associated with the external security Group"
}

variable "vpc_id" {
  description = "The VPC Id to be used for creating the external security group"
}

variable "external_cidr_block" {
  description = "The CIDR range for external IPv4 Addresses"
}

variable "gateway_hostnum" {
  description = "The host number of the gateway in a subnet."
}

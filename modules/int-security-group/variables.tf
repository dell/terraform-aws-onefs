/*

	Copyright (c) 2023 Dell, Inc or its subsidiaries.
	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/


variable "id" {
  default     = null
  description = "The cluster id to be used as a tag in the security group"
}

variable "resource_tags" {
  type = map(string)
  default = {
  }
  description = "The Tags to be associated with the Security Group"
}

variable "network_id" {
  description = "The VPC id to be used for creating the security group"
}


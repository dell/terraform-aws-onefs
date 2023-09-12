/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

provider "aws" {
  region = var.region
}

data "aws_subnet" "internal_subnet" {
  id = var.internal_subnet_id
}

data "aws_subnet" "external_subnet" {
  id = var.external_subnet_id
}

data "aws_subnet" "mgmt_subnet" {
  count = local.enable_mgmt ? 1 : 0
  id    = var.mgmt_subnet_id
}

locals {
  enable_mgmt = var.enable_mgmt == null ? false : var.enable_mgmt
}

module "onefsbase" {
  source = "./modules/base"
  # send everything down
  admin_password                    = var.admin_password
  availability_zone                 = var.availability_zone
  contiguous_ips                    = var.contiguous_ips
  credentials_hashed                = var.credentials_hashed
  data_disk_iops                    = var.data_disk_iops
  data_disk_size                    = var.data_disk_size
  data_disks_per_node               = var.data_disks_per_node
  data_disk_throughput              = var.data_disk_throughput
  data_disk_type                    = var.data_disk_type
  dns_domains                       = var.dns_domains
  dns_servers                       = var.dns_servers
  enable_mgmt                       = local.enable_mgmt
  external_subnet_id                = var.external_subnet_id
  first_external_node_hostnum       = var.first_external_node_hostnum
  first_internal_node_hostnum       = var.first_internal_node_hostnum
  first_mgmt_node_hostnum           = var.first_mgmt_node_hostnum
  http_tokens                       = var.http_tokens
  iam_instance_profile              = var.iam_instance_profile
  id                                = var.id
  instance_type                     = var.instance_type
  internal_sg_id                    = var.internal_sg_id
  internal_subnet_id                = var.internal_subnet_id
  mgmt_subnet_id                    = var.mgmt_subnet_id
  name                              = var.name
  nodes                             = var.nodes
  os_disk_type                      = var.os_disk_type
  partition_count                   = var.partition_count
  placement_group_strategy          = var.placement_group_strategy
  validate_placement_group_strategy = var.validate_placement_group_strategy
  region                            = var.region
  resource_tags                     = var.resource_tags
  root_password                     = var.root_password
  security_group_external_id        = var.security_group_external_id
  security_group_mgmt_id            = var.security_group_mgmt_id
  timezone                          = var.timezone
  validate_instance_type            = var.validate_instance_type
  validate_volume_type              = var.validate_volume_type
  validate_nodes_count              = var.validate_nodes_count
  internal_subnet_cidr_block        = data.aws_subnet.internal_subnet.cidr_block
  external_subnet_cidr_block        = data.aws_subnet.external_subnet.cidr_block
  mgmt_subnet_cidr_block            = local.enable_mgmt ? data.aws_subnet.mgmt_subnet[0].cidr_block : null
  image_id                          = var.image_id
  # Don't alter this format without first consulting these links:
  # https://github.com/hashicorp/terraform/issues/17173
  # https://github.com/hashicorp/terraform-provider-external/issues/4
  hashed_admin_password = var.hashed_admin_passphrase
  hashed_root_password  = var.hashed_root_passphrase
}

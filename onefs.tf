/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

provider "aws" {
  region = var.region
}

data "aws_vpc" "main" {
  id = var.network_id
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

resource "random_id" "admin_salt" {
  keepers = {
    admin_password = var.admin_password
  }

  byte_length = 8
}

resource "random_id" "root_salt" {
  keepers = {
    root_password = var.root_password
  }

  byte_length = 8
}

data "external" "root_passphrase" {
  program = ["python",
    "-m",
    "onefs_workflows.passphrase",
    "--salt",
    "${random_id.root_salt.hex}",
    "--password",
  "${var.root_password}"]
}

data "external" "admin_passphrase" {
  program = ["python",
    "-m",
    "onefs_workflows.passphrase",
    "--salt",
    "${random_id.admin_salt.hex}",
    "--password",
  "${var.admin_password}"]
}

locals {
  enable_mgmt = var.enable_mgmt == null ? false : var.enable_mgmt
}

module "onefsbase" {
  source = "./modules/base"
  # send everything down
  admin_password              = var.admin_password
  availability_zone           = var.availability_zone
  contiguous_ips              = var.contiguous_ips
  credentials_hashed          = var.credentials_hashed
  data_disk_iops              = var.data_disk_iops
  data_disk_size              = var.data_disk_size
  data_disks_per_node         = var.data_disks_per_node
  data_disk_throughput        = var.data_disk_throughput
  data_disk_type              = var.data_disk_type
  dns_domains                 = var.dns_domains
  dns_servers                 = var.dns_servers
  enable_mgmt                 = local.enable_mgmt
  external_subnet_id          = var.external_subnet_id
  first_external_node_hostnum = var.first_external_node_hostnum
  first_internal_node_hostnum = var.first_internal_node_hostnum
  first_mgmt_node_hostnum     = var.first_mgmt_node_hostnum
  gateway_hostnum             = var.gateway_hostnum
  http_tokens                 = var.http_tokens
  iam_instance_profile        = var.iam_instance_profile
  id                          = var.id
  instance_type               = var.instance_type
  internal_sg_id              = var.internal_sg_id
  internal_subnet_id          = var.internal_subnet_id
  linear_journal              = var.linear_journal
  mgmt_subnet_id              = var.mgmt_subnet_id
  name                        = var.name
  network_id                  = var.network_id
  nodes                       = var.nodes
  os_disk_type                = var.os_disk_type
  partition_count             = var.partition_count
  placement_group_strategy    = var.placement_group_strategy
  region                      = var.region
  resource_tags               = var.resource_tags
  root_password               = var.root_password
  security_group_external_id  = var.security_group_external_id
  security_group_mgmt_id      = var.security_group_mgmt_id
  skip_credentials_validation = var.skip_credentials_validation
  skip_metadata_api_check     = var.skip_metadata_api_check
  skip_requesting_account_id  = var.skip_requesting_account_id
  smartconnect_hostnum        = var.smartconnect_hostnum
  smartconnect_zone           = var.smartconnect_zone
  timezone                    = var.timezone
  validate_volume_type        = var.validate_volume_type

  internal_subnet_cidr_block = data.aws_subnet.internal_subnet.cidr_block
  external_subnet_cidr_block = data.aws_subnet.external_subnet.cidr_block
  mgmt_subnet_cidr_block     = local.enable_mgmt ? data.aws_subnet.mgmt_subnet[0].cidr_block : null
  image_id                   = var.image_id
  # Don't alter this format without first consulting these links:
  # https://github.com/hashicorp/terraform/issues/17173
  # https://github.com/hashicorp/terraform-provider-external/issues/4
  hashed_admin_password = lookup(data.external.admin_passphrase.result, "passphrase")
  hashed_root_password  = lookup(data.external.root_passphrase.result, "passphrase")
}


output "control_ip_address" {
  value = module.onefsbase.control_ip_address
}

output "external_ip_addresses" {
  value = module.onefsbase.external_ip_addresses
}

output "root_password" {
  value = module.onefsbase.root_password
}

output "internal_ip_addresses" {
  value = module.onefsbase.internal_ip_addresses
}

output "mgmt_ip_addresses" {
  value = module.onefsbase.mgmt_ip_addresses
}

output "instance_id" {
  value = module.onefsbase.instance_id
}

output "smartconnect_ip" {
  value = module.onefsbase.smartconnect_ip
}

output "additional_nodes" {
  value = module.onefsbase.additional_nodes
}

output "internal_network_low_ip" {
  value = module.onefsbase.internal_network_low_ip
}

output "internal_network_high_ip" {
  value = module.onefsbase.internal_network_high_ip
}

output "node_configs" {
  value = module.onefsbase.node_configs
}

output "gateway_hostnum" {
  value = module.onefsbase.gateway_hostnum
}

output "region" {
  value = module.onefsbase.region
}

output "skip_credentials_validation" {
  value = module.onefsbase.skip_credentials_validation
}

output "skip_requesting_account_id" {
  value = module.onefsbase.skip_requesting_account_id
}

output "skip_metadata_api_check" {
  value = module.onefsbase.skip_metadata_api_check
}

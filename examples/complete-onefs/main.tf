/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

resource "random_pet" "cluster_id" {
  length = 2
}

data "aws_subnet" "external_subnet" {
  id = var.external_subnet_id
}

/* 
If you don't specify the IAM instance profile to be used in the iam_instance_profile input variable,
this module will be called to create the IAM policy, role and instance profile to be used for the
PowerScale clusters
*/
module "onefs_iam_resources" {
  count   = var.iam_instance_profile == null ? 1 : 0
  source  = "../../modules/iam-resources"
  regions = [var.region] # Specify list of AWS regions where you will deploy your PowerScale clusters
}

module "external_security_group" {
  count               = var.external_sg_id == null ? 1 : 0
  source              = "../../modules/ext-security-group"
  cluster_id          = random_pet.cluster_id.id
  vpc_id              = var.vpc_id
  resource_tags       = var.resource_tags
  external_cidr_block = data.aws_subnet.external_subnet.cidr_block
  gateway_hostnum     = module.onefs.gateway_hostnum
}

module "int-sec-group" {
  count         = var.internal_sg_id == null ? 1 : 0
  source        = "../../modules/int-security-group"
  resource_tags = var.resource_tags
  id            = random_pet.cluster_id.id
  network_id    = var.vpc_id
}

module "onefs" {
  source = "../../"

  id                         = var.cluster_id == null ? random_pet.cluster_id.id : var.cluster_id
  name                       = var.cluster_name == null ? random_pet.cluster_id.id : var.cluster_id
  image_id                   = var.image_id
  admin_password             = var.admin_password == null ? var.default_plain_text_password : var.admin_password
  root_password              = var.root_password == null ? var.default_plain_text_password : var.root_password
  availability_zone          = var.availability_zone
  iam_instance_profile       = var.iam_instance_profile == null ? module.onefs_iam_resources[0].powerscale_iam_instance_profile_name : var.iam_instance_profile
  internal_subnet_id         = var.internal_subnet_id
  external_subnet_id         = var.external_subnet_id
  mgmt_subnet_id             = try(var.mgmt_subnet_id, null)
  enable_mgmt                = var.enable_mgmt
  contiguous_ips             = var.contiguous_ips
  credentials_hashed         = var.credentials_hashed
  root_passphrase            = var.root_passphrase == null ? var.default_hashed_password : var.root_passphrase
  admin_passphrase           = var.admin_passphrase == null ? var.default_hashed_password : var.admin_passphrase
  security_group_external_id = var.external_sg_id == null ? module.external_security_group[0].external_sg_id : var.external_sg_id
  security_group_mgmt_id     = try(var.mgmt_sg_id, null)
  nodes                      = var.nodes
  instance_type              = var.instance_type
  resource_tags              = var.resource_tags
  os_disk_type               = var.os_disk_type
  validate_volume_type       = var.validate_volume_type
  validate_nodes_count       = var.validate_nodes_count
  data_disk_type             = var.data_disk_type
  data_disk_iops             = var.data_disk_iops
  data_disk_throughput       = var.data_disk_throughput
  data_disk_size             = var.data_disk_size
  placement_group_strategy   = var.placement_group_strategy
  partition_count            = var.partition_count
  internal_sg_id             = var.internal_sg_id == null ? module.int-sec-group[0].security_group_id : var.internal_sg_id
}

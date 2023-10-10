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

locals {
  gateway_hostnum = 1
}

module "external_security_group" {
  source              = "dell/onefs/aws//modules/ext-security-group"
  cluster_id          = var.cluster_id == null ? random_pet.cluster_id.id : var.cluster_id
  vpc_id              = var.vpc_id
  resource_tags       = var.resource_tags
  external_cidr_block = data.aws_subnet.external_subnet.cidr_block
  gateway_hostnum     = local.gateway_hostnum
}

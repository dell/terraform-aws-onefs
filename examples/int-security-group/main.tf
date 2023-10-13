/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

resource "random_pet" "cluster_id" {
  length = 2
}

module "int-sec-group" {
  source        = "../../modules/int-security-group"
  resource_tags = var.resource_tags
  id            = var.cluster_id == null ? random_pet.cluster_id.id : var.cluster_id
  network_id    = var.vpc_id
}

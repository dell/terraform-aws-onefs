/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/
output "cluster_id" {
  value = module.onefs.cluster_id
}

output "first_node_external_ip_address" {
  value = module.onefs.node_configs[0].external_ips[0]
}

output "first_node_instance_id" {
  value = module.onefs.instance_id[0]
}

output "additional_nodes_external_ip_addresses" {
  value = [for each_index in range(1, length(module.onefs.node_configs)) : module.onefs.node_configs[each_index].external_ips[0]]
}

output "internal_network_low_ip" {
  value = module.onefs.internal_network_low_ip
}

output "internal_network_high_ip" {
  value = module.onefs.internal_network_high_ip
}

output "region" {
  value = var.region
}
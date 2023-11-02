/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

output "control_ip_address" {
  value = module.onefsbase.control_ip_address
}

output "external_ip_addresses" {
  value = module.onefsbase.external_ip_addresses
}

output "root_password" {
  value     = module.onefsbase.root_password
  sensitive = true
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

output "cluster_id" {
  value = module.onefsbase.cluster_id
}
/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

output "control_ip_address" {
  value       = local.control_ip_address
  description = "IP address that can be used to control/manage the cluster."
}

output "external_ip_addresses" {
  value       = aws_network_interface.external_interface[*].private_ip
  description = "External Private IP addresses of all the cluster nodes."
}

output "root_password" {
  value       = var.root_password
  sensitive   = true
  description = "Root Password of the cluster."
}

# Don't delete this/comment this out without updating aws-cluster-lifecycle-worker first
output "internal_ip_addresses" {
  value       = aws_network_interface.internal_interface[*].private_ip
  description = "Internal Private IP addresses of cluster nodes."
}

output "mgmt_ip_addresses" {
  value       = var.enable_mgmt ? aws_network_interface.mgmt_interface[*].private_ip : []
  description = "Management Private IP addresses of cluster nodes, applicable only if enable_mgmt is true."
}

output "instance_id" {
  value       = try(aws_instance.onefs_node[*].id, [])
  description = "Instance ID of all the cluster nodes(EC2 VMs)."
}

output "additional_nodes" {
  value       = local.additional_nodes
  description = "Number cluster nodes created minus 1, which means additional_nodes value is 2 if 3 node cluster is created."
}

output "internal_network_low_ip" {
  value       = local.internal_network_config.low_ip
  description = "Low IP address in the internal subnet pool."
}

output "internal_network_high_ip" {
  value       = local.internal_network_config.high_ip
  description = "High IP address in the internal subnet pool"
}

output "node_configs" {
  value       = local.node_configs
  description = "Configuration of OneFS cluster node like serial number, internal, external & management network interface IDs and IPs"
}

output "gateway_hostnum" {
  value       = var.gateway_hostnum
  description = "The host number of the gateway in a subnet."
}

output "region" {
  value       = var.region
  description = "AWS region where the cluster resources were created"
}

output "cluster_id" {
  value       = var.id
  description = "The Unique Identifier used for a particular PowerScale cluster."
}

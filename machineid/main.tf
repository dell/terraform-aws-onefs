variable index {}
variable cluster_config {}
variable devices {}
variable node_configs {}
variable internal_network_config {}
variable external_network_config {}
variable mgmt_network_config {}
variable external_ips {}
variable mgmt_ips {}
variable enable_mgmt {}

locals {
    machineid = jsonencode(jsondecode(
    templatefile("${path.module}/machineid.template.json", {
      cluster_config          = var.cluster_config
      devices                 = var.devices
      node_config             = var.node_configs[var.index]
      node_number             = var.index
      internal_network_config = var.internal_network_config
      external_network_config = var.external_network_config
      mgmt_network_config     = var.mgmt_network_config
      external_ip             = var.external_ips[var.index]
      mgmt_ip                 = var.enable_mgmt ? var.mgmt_ips[var.index] : null
    })
  ))
}

output "machineid" {
  value = local.machineid
}

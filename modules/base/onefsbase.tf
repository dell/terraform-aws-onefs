/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

locals {
  resource_tags = merge(
    var.resource_tags,
    {
      ClusterID : var.id
    }
  )
}

locals {
  pg_spread_max_instances           = 7
  pg_partition_default_partitions   = 7
  gateway_hostnum                   = 1
  min_cluster_size                  = 1
  default_allowed_data_disk_size    = 16
  default_allowed_data_disks_count  = 5
  nodes                             = var.nodes == null ? 4 : var.nodes
  placement_group_strategy          = var.placement_group_strategy == null ? local.allowed_placement_group_strategies[0] : var.placement_group_strategy
  partition_count                   = var.partition_count == null ? (local.placement_group_strategy == "partition" ? local.pg_partition_default_partitions : 0) : var.partition_count
  contiguous_ips                    = var.contiguous_ips == null ? false : var.contiguous_ips
  additional_nodes                  = local.nodes - local.min_cluster_size
  data_disk_type                    = var.data_disk_type == null ? local.allowed_data_disk_types.gp3 : var.data_disk_type
  instance_type                     = var.instance_type == null ? local.allowed_instance_types[0] : var.instance_type
  os_disk_type                      = var.os_disk_type == null ? local.allowed_os_disk_types.gp3 : var.os_disk_type
  validate_os_disk_type             = var.validate_os_disk_type == null ? true : var.validate_os_disk_type
  validate_instance_type            = var.validate_instance_type == null ? true : var.validate_instance_type
  validate_volume_type              = var.validate_volume_type == null ? true : var.validate_volume_type
  validate_nodes_count              = var.validate_nodes_count == null ? true : var.validate_nodes_count
  validate_data_disk_size           = var.validate_data_disk_size == null ? true : var.validate_data_disk_size
  validate_data_disks_count         = var.validate_data_disks_count == null ? true : var.validate_data_disks_count
  validate_placement_group_strategy = var.validate_placement_group_strategy == null ? true : var.validate_placement_group_strategy

  data_disks_per_node = var.data_disks_per_node == null ? (contains(values(local.allowed_data_disk_types), local.data_disk_type) ?
    local.allowed_data_disks_count_map[local.data_disk_type][0] :
  local.default_allowed_data_disks_count) : var.data_disks_per_node

  data_disk_size = var.data_disk_size == null ? (contains(values(local.allowed_data_disk_types), local.data_disk_type) ?
    (can(local.allowed_data_disk_sizes[local.data_disk_type].min) ?
      local.allowed_data_disk_sizes[local.data_disk_type].min :
    local.allowed_data_disk_sizes[local.data_disk_type][0]) :
  local.default_allowed_data_disk_size) : var.data_disk_size

  allowed_placement_group_strategies = ["spread"]
  allowed_instance_types             = ["m5dn.8xlarge", "m5dn.12xlarge", "m5dn.16xlarge", "m5dn.24xlarge", "m5d.24xlarge", "m6idn.8xlarge", "m6idn.12xlarge", "m6idn.16xlarge", "m6idn.24xlarge"]
  allowed_os_disk_types              = { gp3 = "gp3" }
  allowed_data_disk_types = {
    gp3 = "gp3"
    st1 = "st1"
  }
  allowed_data_disks_count_map = {
    gp3 = [5, 6, 10, 12, 15, 18, 20]
    st1 = [5, 6]
  }
  # allowed_data_disk_sizes can have either a list of values or a map with min & max parameters
  allowed_data_disk_sizes = {
    gp3 = {
      min = 1024
      max = 16384
    }
    st1 = [4096, 10240]
  }
  external_network_config = {
    ip_address_ranges = local.contiguous_ips ? [{
      "low"  = cidrhost(var.external_subnet_cidr_block, var.first_external_node_hostnum)
      "high" = cidrhost(var.external_subnet_cidr_block, var.first_external_node_hostnum + local.nodes - 1)
      }] : [for node_number in range(local.nodes) : {
      "low" : aws_network_interface.external_interface[node_number].private_ip
      "high" : aws_network_interface.external_interface[node_number].private_ip
    }]
    gateway_ip      = cidrhost(var.external_subnet_cidr_block, local.gateway_hostnum)
    dns_servers     = var.dns_servers
    dns_domains     = var.dns_domains == null ? ["${var.region}.compute.internal"] : var.dns_domains
    network_mask    = cidrnetmask(var.external_subnet_cidr_block)
    security_groups = [var.security_group_external_id]
    subnet          = var.external_subnet_id
  }
  internal_network_config = {
    network_mask    = cidrnetmask(var.internal_subnet_cidr_block)
    low_ip          = cidrhost(var.internal_subnet_cidr_block, var.first_internal_node_hostnum)
    high_ip         = cidrhost(var.internal_subnet_cidr_block, var.first_internal_node_hostnum + local.nodes - 1)
    security_groups = [var.internal_sg_id]
    subnet          = var.internal_subnet_id
  }
  mgmt_network_config = try(
    {
      enabled = true
      ip_address_ranges = local.contiguous_ips ? [{
        "low"  = cidrhost(var.mgmt_subnet_cidr_block, var.first_mgmt_node_hostnum)
        "high" = cidrhost(var.mgmt_subnet_cidr_block, var.first_mgmt_node_hostnum + local.nodes - 1)
        }] : [for node_number in range(local.nodes) : {
        "low" : aws_network_interface.mgmt_interface[node_number].private_ip
        "high" : aws_network_interface.mgmt_interface[node_number].private_ip
      }]
      gateway_ip      = cidrhost(var.mgmt_subnet_cidr_block, local.gateway_hostnum)
      network_mask    = cidrnetmask(var.mgmt_subnet_cidr_block)
      security_groups = [var.security_group_mgmt_id]
      subnet          = var.mgmt_subnet_id
    },
    null
  )
  cluster_config = {
    availability_zone    = var.availability_zone
    id                   = var.id
    name                 = var.name
    resource_tags        = local.resource_tags
    image_id             = var.image_id
    iam_instance_profile = var.iam_instance_profile
    instance_type        = local.instance_type
    credentials_hashed   = var.credentials_hashed
    admin_password       = var.admin_password
    root_password        = var.root_password
    # Don't alter this format without first consulting these links:
    # https://github.com/hashicorp/terraform/issues/17173
    # https://github.com/hashicorp/terraform-provider-external/issues/4
    hashed_admin_password     = var.hashed_admin_password
    hashed_root_password      = var.hashed_root_password
    timezone                  = var.timezone == null ? "Greenwich Mean Time" : var.timezone
    os_disk_type              = local.os_disk_type
    data_disks_per_node       = local.data_disks_per_node
    data_disk_size            = local.data_disk_size
    data_disk_type            = local.data_disk_type
    data_disk_iops            = var.data_disk_iops
    data_disk_throughput      = var.data_disk_throughput
    validate_instance_type    = local.validate_instance_type
    validate_os_disk_type     = local.validate_os_disk_type
    validate_volume_type      = local.validate_volume_type
    validate_nodes_count      = local.validate_nodes_count
    validate_data_disks_count = local.validate_data_disks_count
    validate_data_disk_size   = local.validate_data_disk_size
  }
  node_configs = {
    for node_number in range(local.nodes) : node_number => {
      serial_number : module.machineid.serial_numbers[node_number]
      external_interface_id : aws_network_interface.external_interface[node_number].id
      internal_interface_id : aws_network_interface.internal_interface[node_number].id
      mgmt_interface_id : var.enable_mgmt ? aws_network_interface.mgmt_interface[node_number].id : null
      internal_ips : [cidrhost(var.internal_subnet_cidr_block, node_number + var.first_internal_node_hostnum)]
      external_ips : [aws_network_interface.external_interface[node_number].private_ip]
      mgmt_ips : var.enable_mgmt ? [aws_network_interface.mgmt_interface[node_number].private_ip] : null
    }
  }
  http_tokens = var.http_tokens == null ? "required" : var.http_tokens
}

resource "aws_network_interface" "internal_interface" {
  count           = local.nodes
  subnet_id       = var.internal_subnet_id
  private_ips     = [cidrhost(var.internal_subnet_cidr_block, count.index + var.first_internal_node_hostnum)]
  security_groups = [var.internal_sg_id]

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.id}-nic-int-${count.index}"
    }
  )
}

resource "aws_network_interface" "external_interface" {
  count             = local.nodes
  subnet_id         = var.external_subnet_id
  security_groups   = [var.security_group_external_id]
  private_ips       = local.contiguous_ips ? [cidrhost(var.external_subnet_cidr_block, count.index + var.first_external_node_hostnum)] : null
  private_ips_count = local.contiguous_ips ? null : (count.index == 0 ? 1 : 0)

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.id}-nic-ext-${count.index}"
    }
  )

  lifecycle {
    ignore_changes = [
      private_ips,
    ]
  }
}

resource "aws_network_interface" "mgmt_interface" {
  count           = var.enable_mgmt ? local.nodes : 0
  subnet_id       = var.mgmt_subnet_id
  security_groups = [var.security_group_mgmt_id]
  private_ips     = local.contiguous_ips ? [cidrhost(var.mgmt_subnet_cidr_block, count.index + var.first_mgmt_node_hostnum)] : null

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.id}-nic-mgmt-${count.index}"
    }
  )

  lifecycle {
    ignore_changes = [
      private_ips,
    ]
  }
}

resource "aws_placement_group" "onefs_placement_group" {
  name     = "${var.id}-onefs-placement-group"
  strategy = local.placement_group_strategy
  tags = merge(
    local.resource_tags,
    {
      Name = "${var.id}-onefs-placement-group"
    }
  )

  partition_count = local.partition_count

  lifecycle {
    precondition {
      condition = local.validate_placement_group_strategy ? contains(
        local.allowed_placement_group_strategies,
        local.placement_group_strategy
      ) : true
      error_message = join("", [
        "EC2 placement group strategy provided: \"${local.placement_group_strategy}\" for \"placement_group_strategy\" ",
        "variable is invalid. Allowed placement group strategies for OneFS nodes ",
        "${length(local.allowed_placement_group_strategies) <= 1 ? "is" : "are"}: ",
        "${join(", ", local.allowed_placement_group_strategies)}. Disable placement group strategy validation by setting ",
        "\"validate_placement_group_strategy\" to false."
      ])
    }

    precondition {
      condition = (
        !(local.nodes > local.pg_spread_max_instances && local.placement_group_strategy == "spread")
      )
      error_message = join("", [
        "Note: The 'spread' placement group strategy can only support ",
        "seven running instances per availability zone.",
        "The 'cluster' and 'partition' placement group can support more and span multiple zones."
      ])
    }

    precondition {
      condition = (
        ((local.placement_group_strategy != "partition" && local.partition_count == 0) || (local.placement_group_strategy == "partition"))
      )
      error_message = join("", [
        "The 'partition_count' is only set for 'partition' placement group strategy"
      ])
    }

    ignore_changes = [
      spread_level
    ]
  }

}

module "machineid" {
  source                = "../machineid"
  nodes                 = local.nodes
  name                  = var.name
  timezone              = local.cluster_config.timezone
  enable_mgmt           = var.enable_mgmt
  data_disk_type        = local.data_disk_type
  internal_ips          = aws_network_interface.internal_interface[*].private_ip
  external_ips          = aws_network_interface.external_interface[*].private_ip
  mgmt_ips              = try(aws_network_interface.mgmt_interface[*].private_ip, null)
  internal_network_mask = local.internal_network_config.network_mask
  external_network_mask = local.external_network_config.network_mask
  external_gateway_ip   = local.external_network_config.gateway_ip
  mgmt_network_mask     = try(local.mgmt_network_config.network_mask, null)
  mgmt_gateway_ip       = try(local.mgmt_network_config.gateway_ip, null)
  dns_servers           = local.external_network_config.dns_servers
  dns_domains           = local.external_network_config.dns_domains
  credentials_hashed    = var.credentials_hashed
  hashed_root_password  = local.cluster_config.hashed_root_password
  hashed_admin_password = local.cluster_config.hashed_admin_password
  root_password         = var.root_password
  admin_password        = var.admin_password
}


resource "aws_instance" "onefs_node" {
  count                = local.nodes
  ami                  = local.cluster_config.image_id
  iam_instance_profile = local.cluster_config.iam_instance_profile
  instance_type        = local.cluster_config.instance_type
  availability_zone    = local.cluster_config.availability_zone
  placement_group      = aws_placement_group.onefs_placement_group.id

  user_data = module.machineid.machineid[count.index]

  metadata_options {
    http_tokens   = local.http_tokens
    http_endpoint = "enabled" # https://github.com/hashicorp/terraform-provider-aws/issues/12564
  }

  tags = merge(
    local.cluster_config.resource_tags,
    {
      Name = "${local.cluster_config.id}-node-${count.index}"
    }
  )

  dynamic "network_interface" {
    for_each = range(var.enable_mgmt ? 1 : 0)
    content {
      device_index         = 2
      network_interface_id = aws_network_interface.mgmt_interface[count.index].id
    }
  }

  network_interface {
    network_interface_id = aws_network_interface.external_interface[count.index].id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.internal_interface[count.index].id
    device_index         = 0
  }

  root_block_device {
    volume_size = var.os_disk_size
    volume_type = local.cluster_config.os_disk_type

    tags = merge(
      local.cluster_config.resource_tags,
      {
        Name = "${local.cluster_config.id}-node-os-${count.index}"
      }
    )
  }

  dynamic "ebs_block_device" {
    for_each = range(local.cluster_config.data_disks_per_node)

    content {
      device_name = "xvd${substr("abcdefghijklmnopqrstuvwxyz", ebs_block_device.key, 1)}"
      volume_size = local.cluster_config.data_disk_size
      volume_type = local.cluster_config.data_disk_type
      iops        = local.cluster_config.data_disk_iops
      throughput  = local.cluster_config.data_disk_throughput


      tags = merge(
        local.cluster_config.resource_tags,
        {
          Name = "${local.cluster_config.id}-node-data-${count.index}-${ebs_block_device.key}"
        }
      )
    }
  }
  lifecycle {
    precondition {
      condition = local.cluster_config.validate_volume_type ? contains(
        values(local.allowed_data_disk_types),
        local.cluster_config.data_disk_type
      ) : true
      error_message = join("", [
        "AWS volume type provided \"${local.cluster_config.data_disk_type}\" for \"data_disk_type\" ",
        "variable is invalid. Allowed values for EBS volume type are: ${join(", ", values(local.allowed_data_disk_types))}. ",
        "Disable volume type validation by setting \"validate_volume_type\" to false."
      ])
    }
    precondition {
      condition = local.cluster_config.validate_data_disks_count ? (
        local.cluster_config.data_disk_type == local.allowed_data_disk_types.gp3 ? contains(
          local.allowed_data_disks_count_map.gp3, local.cluster_config.data_disks_per_node
          ) : local.cluster_config.data_disk_type == local.allowed_data_disk_types.st1 ? contains(
          local.allowed_data_disks_count_map.st1, local.cluster_config.data_disks_per_node
        ) : true
      ) : true
      error_message = join("", [
        "Number of EBS volumes requested to be attached to each OneFS Node: \"${local.cluster_config.data_disks_per_node}\" ",
        "of volume type: \"${local.cluster_config.data_disk_type}\" for variable \"data_disks_per_node\" is invalid. ",
        "Allowed number of EBS volumes to be attached to each OneFS Node are:\n",
        "${jsonencode(local.allowed_data_disks_count_map)}\n",
        "Disable EBS volumes per node count validation by setting \"validate_data_disks_count\" to false."
      ])
    }
    precondition {
      condition = local.cluster_config.validate_data_disk_size ? (
        local.cluster_config.data_disk_type == local.allowed_data_disk_types.gp3 ?
        tonumber(local.cluster_config.data_disk_size) >= tonumber(local.allowed_data_disk_sizes.gp3.min) &&
        tonumber(local.cluster_config.data_disk_size) <= tonumber(local.allowed_data_disk_sizes.gp3.max) :
        local.cluster_config.data_disk_type == local.allowed_data_disk_types.st1 ? contains(
          local.allowed_data_disk_sizes.st1, local.cluster_config.data_disk_size
        ) : true
      ) : true
      error_message = join("", [
        "AWS volume size provided: \"${local.cluster_config.data_disk_size}\" GiBs ",
        "of data_disk_type: \"${local.cluster_config.data_disk_type}\" for variable \"data_disk_size\" is invalid. ",
        "Allowed volume sizes for data_disk_size variable for data_disk_type:\n",
        "${jsonencode(local.allowed_data_disk_sizes)}\n",
        "Disable volume size validation by setting \"validate_data_disk_size\" to false."
      ])
    }
    precondition {
      condition = local.cluster_config.validate_instance_type ? contains(
        local.allowed_instance_types,
        local.cluster_config.instance_type
      ) : true
      error_message = "EC2 Instance type provided \"${local.cluster_config.instance_type}\" for \"instance_type\" variable is invalid. Allowed Instance types for OneFS nodes are ${join(", ", local.allowed_instance_types)}. Disable Instance type validation by setting \"validate_instance_type\" to false."
    }
    precondition {
      condition     = local.cluster_config.validate_nodes_count ? (var.nodes >= 4 && var.nodes <= 6) : true
      error_message = "Number of nodes specified: \"${local.nodes}\" doesn't fall in the valid range for number of nodes, i.e. 4-6. Disable nodes` count validation by setting \"validate_nodes_count\" to false."
    }
    precondition {
      condition = local.cluster_config.validate_os_disk_type ? contains(
        values(local.allowed_os_disk_types),
        local.cluster_config.os_disk_type
      ) : true
      error_message = "OS Disk type provided \"${local.cluster_config.os_disk_type}\" for \"os_disk_type\" variable is invalid. Allowed OS Disk Types for OneFS nodes are \"${join(", ", values(local.allowed_os_disk_types))}\". Disable OS Disk Type validation by setting \"validate_os_disk_type\" to false."
    }
    ignore_changes = [
      user_data,
    ]
  }
}

locals {
  # This is a workaround until https://jira.cec.lab.emc.com/browse/OCM-3708 can be reported and then resolved
  control_ip_address = var.enable_mgmt ? try(aws_network_interface.mgmt_interface[0].private_ip, null) : try(aws_network_interface.external_interface[0].private_ip, null)
}

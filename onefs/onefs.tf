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

data "aws_ami" "onefs_ami" {
  filter {
    name   = "image-id"
    values = [local.image_id]
  }
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

data "aws_ami_ids" "onefs_ami_id" {
  owners = ["self"]
  filter {
    name   = "tag:onefs_build"
    values = [local.onefs_build]
  }
  filter {
    name   = "tag:deployment_method"
    values = ["onefs_official"]
  }
}

locals {
  resource_tags = merge(
    var.resource_tags,
    {
      ClusterID : var.id
    }
  )
}

#
#  INTERNAL Networking Inteface Security Group & Rules
#
resource "aws_security_group" "internal" {
  name   = "${var.id}-sg-internal-iface"
  vpc_id = data.aws_vpc.main.id

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.id}-sg-ingress"
    }
  )
}

# only allow inbound allow traffic originating from this security group
resource "aws_security_group_rule" "internal_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.internal.id
}

resource "aws_security_group_rule" "internal_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.internal.id
}

locals {
  nodes                           = var.nodes == null ? 3 : var.nodes
  pg_spread_max_instances         = 7
  placement_group_strategy        = var.placement_group_strategy == null ? "spread" : var.placement_group_strategy
  pg_partition_default_partitions = 7
  partition_count                 = var.partition_count == null ? (local.placement_group_strategy == "partition" ? local.pg_partition_default_partitions : 0) : var.partition_count
  data_disk_type                  = var.data_disk_type == null ? "gp3" : var.data_disk_type
  os_disk_type                    = var.os_disk_type == null ? "gp3" : var.os_disk_type
  validate_volume_type            = var.validate_volume_type == null ? true : var.validate_volume_type
  data_disks_per_node             = var.data_disks_per_node == null ? 5 : var.data_disks_per_node
  onefs_build                     = var.onefs_build == null ? "b.9.6.0.004r" : var.onefs_build
  ami_id                          = try(data.aws_ami_ids.onefs_ami_id.ids[0], null)
  image_id                        = var.image_id == null ? local.ami_id : var.image_id
  instance_type                   = var.instance_type == null ? "m5d.large" : var.instance_type
  data_disk_size                  = var.data_disk_size == null ? 16 : var.data_disk_size
  enable_mgmt                     = var.enable_mgmt == null ? false : var.enable_mgmt
  contiguous_ips                  = var.contiguous_ips == null ? false : var.contiguous_ips
  min_cluster_size                = 1
  additional_nodes                = local.nodes - local.min_cluster_size
  external_network_config = {
    # Check all external ifaces as SSIP can move off node 1.
    smartconnect_ip = local.contiguous_ips ? cidrhost(data.aws_subnet.external_subnet.cidr_block, var.smartconnect_hostnum) : tolist(
      setsubtract(
        toset(flatten([for nic in aws_network_interface.external_interface[*] : nic.private_ips])),
        toset([for nic in aws_network_interface.external_interface[*] : nic.private_ip])
      )
    )[0]
    smartconnect_zone = var.smartconnect_zone == null ? local.cluster_config.name + ".internal" : var.smartconnect_zone
    ip_address_ranges = local.contiguous_ips ? [{
      "low"  = cidrhost(data.aws_subnet.external_subnet.cidr_block, var.first_external_node_hostnum)
      "high" = cidrhost(data.aws_subnet.external_subnet.cidr_block, var.first_external_node_hostnum + local.nodes - 1)
      }] : [for node_number in range(local.nodes) : {
      "low" : aws_network_interface.external_interface[node_number].private_ip
      "high" : aws_network_interface.external_interface[node_number].private_ip
    }]
    gateway_ip      = cidrhost(data.aws_subnet.external_subnet.cidr_block, var.gateway_hostnum)
    dns_servers     = var.dns_servers
    dns_domains     = var.dns_domains
    network_mask    = cidrnetmask(data.aws_subnet.external_subnet.cidr_block)
    security_groups = [var.security_group_external_id]
    subnet          = data.aws_subnet.external_subnet.id
  }
  internal_network_config = {
    network_mask    = cidrnetmask(data.aws_subnet.internal_subnet.cidr_block)
    low_ip          = cidrhost(data.aws_subnet.internal_subnet.cidr_block, var.first_internal_node_hostnum)
    high_ip         = cidrhost(data.aws_subnet.internal_subnet.cidr_block, var.first_internal_node_hostnum + local.nodes - 1)
    security_groups = [aws_security_group.internal.id]
    subnet          = data.aws_subnet.internal_subnet.id
  }
  mgmt_network_config = try(
    {
      enabled = true
      ip_address_ranges = local.contiguous_ips ? [{
        "low"  = cidrhost(data.aws_subnet.mgmt_subnet[0].cidr_block, var.first_mgmt_node_hostnum)
        "high" = cidrhost(data.aws_subnet.mgmt_subnet[0].cidr_block, var.first_mgmt_node_hostnum + local.nodes - 1)
        }] : [for node_number in range(local.nodes) : {
        "low" : aws_network_interface.mgmt_interface[node_number].private_ip
        "high" : aws_network_interface.mgmt_interface[node_number].private_ip
      }]
      gateway_ip      = cidrhost(data.aws_subnet.mgmt_subnet[0].cidr_block, var.gateway_hostnum)
      network_mask    = cidrnetmask(data.aws_subnet.mgmt_subnet[0].cidr_block)
      security_groups = [var.security_group_mgmt_id]
      subnet          = data.aws_subnet.mgmt_subnet[0].id
    },
    null
  )
  cluster_config = {
    availability_zone    = var.availability_zone
    id                   = var.id
    name                 = var.name
    resource_tags        = local.resource_tags
    image_id             = data.aws_ami.onefs_ami.image_id
    iam_instance_profile = var.iam_instance_profile
    instance_type        = local.instance_type
    credentials_hashed   = var.credentials_hashed
    admin_password       = var.admin_password
    root_password        = var.root_password
    # Don't alter this format without first consulting these links:
    # https://github.com/hashicorp/terraform/issues/17173
    # https://github.com/hashicorp/terraform-provider-external/issues/4
    hashed_admin_password = lookup(data.external.admin_passphrase.result, "passphrase")
    hashed_root_password  = lookup(data.external.root_passphrase.result, "passphrase")
    timezone              = var.timezone
    os_disk_type          = local.os_disk_type
    data_disks_per_node   = local.data_disks_per_node
    data_disk_size        = local.data_disk_size
    data_disk_type        = local.data_disk_type
    data_disk_iops        = var.data_disk_iops
    data_disk_throughput  = var.data_disk_throughput
    validate_volume_type  = local.validate_volume_type
  }
  node_configs = {
    for node_number in range(local.nodes) : node_number => {
      serial_number : "SV200-930073-${format("%04d", node_number)}"
      external_interface_id : aws_network_interface.external_interface[node_number].id
      internal_interface_id : aws_network_interface.internal_interface[node_number].id
      mgmt_interface_id : local.enable_mgmt ? aws_network_interface.mgmt_interface[node_number].id : null
      internal_ips : [cidrhost(data.aws_subnet.internal_subnet.cidr_block, node_number + var.first_internal_node_hostnum)]
      external_ips : [aws_network_interface.external_interface[node_number].private_ip]
      mgmt_ips : local.enable_mgmt ? [aws_network_interface.mgmt_interface[node_number].private_ip] : null
    }
  }
  http_tokens = var.http_tokens == null ? "required" : var.http_tokens
}

resource "aws_network_interface" "internal_interface" {
  count           = local.nodes
  subnet_id       = data.aws_subnet.internal_subnet.id
  private_ips     = [cidrhost(data.aws_subnet.internal_subnet.cidr_block, count.index + var.first_internal_node_hostnum)]
  security_groups = [aws_security_group.internal.id]

  tags = merge(
    local.resource_tags,
    {
      Name = "${var.id}-nic-int-${count.index}"
    }
  )
}

resource "aws_network_interface" "external_interface" {
  count             = local.nodes
  subnet_id         = data.aws_subnet.external_subnet.id
  security_groups   = [var.security_group_external_id]
  private_ips       = local.contiguous_ips ? [cidrhost(data.aws_subnet.external_subnet.cidr_block, count.index + var.first_external_node_hostnum)] : null
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
  count           = local.enable_mgmt ? local.nodes : 0
  subnet_id       = data.aws_subnet.mgmt_subnet[0].id
  security_groups = [var.security_group_mgmt_id]
  private_ips     = local.contiguous_ips ? [cidrhost(data.aws_subnet.mgmt_subnet[0].cidr_block, count.index + var.first_mgmt_node_hostnum)] : null

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
      Name = "${var.id}-placement-group"
    }
  )

  partition_count = local.partition_count

  lifecycle {
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
  serial_numbers        = [for index in range(local.nodes) : local.node_configs[index].serial_number]
  enable_mgmt           = local.enable_mgmt
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
    for_each = range(local.enable_mgmt ? 1 : 0)
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
        ["gp3"],
        local.cluster_config.data_disk_type
      ) : true
      error_message = "AWS volume type provided \"${local.cluster_config.data_disk_type}\" for \"data_disk_type\" variable is invalid. Disable volume type validation by setting \"validate_volume_type\" to false."
    }
    ignore_changes = [
      user_data,
    ]
  }
}


locals {
  # This is a workaround until https://jira.cec.lab.emc.com/browse/OCM-3708 can be reported and then resolved
  control_ip_address = local.enable_mgmt ? try(aws_network_interface.mgmt_interface[0].private_ip, null) : try(aws_network_interface.external_interface[0].private_ip, null)
}

output "control_ip_address" {
  value = local.control_ip_address
}

output "external_ip_addresses" {
  value = aws_network_interface.external_interface[*].private_ip
}

output "root_password" {
  value     = var.root_password
  sensitive = true
}

# Don't delete this/comment this out without updating aws-cluster-lifecycle-worker first
output "internal_ip_addresses" {
  value = aws_network_interface.internal_interface[*].private_ip
}

output "mgmt_ip_addresses" {
  value = local.enable_mgmt ? aws_network_interface.mgmt_interface[*].private_ip : []
}

output "instance_id" {
  value = try(aws_instance.onefs_node[*].id, [])
}

output "smartconnect_ip" {
  value = local.external_network_config.smartconnect_ip
}

output "additional_nodes" {
  value = local.additional_nodes
}

output "internal_network_low_ip" {
  value = local.internal_network_config.low_ip
}

output "internal_network_high_ip" {
  value = local.internal_network_config.high_ip
}

output "node_configs" {
  value = local.node_configs
}

output "gateway_hostnum" {
  value = var.gateway_hostnum
}

output "region" {
  value = var.region
}


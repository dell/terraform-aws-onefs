/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

resource "aws_security_group" "external" {
  name   = "${var.cluster_id}-sg-external"
  vpc_id = var.vpc_id
  tags = merge(
    var.resource_tags,
    {
      Name = "${var.cluster_id}-sg-external"
    }
  )
}

resource "aws_security_group_rule" "papi" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

# ICMP: Echo Request and Echo Reply
resource "aws_security_group_rule" "icmp-echo-i4" {
  type              = "ingress"
  from_port         = 8 # type
  to_port           = 0 # code
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

# ICMP: fragmentation needed
resource "aws_security_group_rule" "icmp-frag-i4" {
  type              = "ingress"
  from_port         = 3
  to_port           = 4
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

# ICMP: time exceeded (needed for traceroute)
resource "aws_security_group_rule" "icmp-ttl-i4" {
  type              = "ingress"
  from_port         = 11
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-dns" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-dns" {
  type              = "ingress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-rpc-bind" {
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-rpc-bind" {
  type              = "ingress"
  from_port         = 111
  to_port           = 111
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-dcerpc" {
  type              = "ingress"
  from_port         = 135
  to_port           = 135
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-dcerpc" {
  type              = "ingress"
  from_port         = 135
  to_port           = 135
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-mountd" {
  type              = "ingress"
  from_port         = 300
  to_port           = 300
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-mountd" {
  type              = "ingress"
  from_port         = 300
  to_port           = 300
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-statd" {
  type              = "ingress"
  from_port         = 302
  to_port           = 302
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-statd" {
  type              = "ingress"
  from_port         = 302
  to_port           = 302
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-lockd" {
  type              = "ingress"
  from_port         = 304
  to_port           = 304
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-lockd" {
  type              = "ingress"
  from_port         = 304
  to_port           = 304
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-nfsquotad" {
  type              = "ingress"
  from_port         = 305
  to_port           = 305
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-nfsquotad" {
  type              = "ingress"
  from_port         = 305
  to_port           = 305
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "tcp-nfsmgmtd" {
  type              = "ingress"
  from_port         = 306
  to_port           = 306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "udp-nfsmgmtd" {
  type              = "ingress"
  from_port         = 306
  to_port           = 306
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "microsoft-ds" {
  type              = "ingress"
  from_port         = 445
  to_port           = 445
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "s3-http" {
  type              = "ingress"
  from_port         = 9020
  to_port           = 9020
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "s3-https" {
  type              = "ingress"
  from_port         = 9021
  to_port           = 9021
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "nfsv3-rdma" {
  type              = "ingress"
  from_port         = 20049
  to_port           = 20049
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "dhcp" {
  type              = "ingress"
  from_port         = 67
  to_port           = 68
  protocol          = "udp"
  cidr_blocks       = [join("/", [cidrhost(var.external_cidr_block, var.gateway_hostnum), "32"])]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "All"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.external.id
}

/*

	Copyright (c) 2023 Dell, Inc or its subsidiaries.
	
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/



resource "aws_security_group" "internal" {
  name   = "${var.id}-sg-internal-iface"
  vpc_id = data.aws_vpc.main.id

  tags = merge(
    var.resource_tags,
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

/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "powerscale_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "powerscale_instance_policy" {
  statement {
    actions = [
      "ec2:AssignPrivateIpAddresses"
    ]
    resources = [for each_region in var.regions : "arn:aws:ec2:${each_region}:${data.aws_caller_identity.current.account_id}:network-interface/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "powerscale_iam_instance_policy" {
  name        = "${data.aws_caller_identity.current.account_id}-powerscale-node-runtime-policy"
  description = "powerscale IAM policy for create and destroy."
  path        = "/"
  policy      = data.aws_iam_policy_document.powerscale_instance_policy.json
}

resource "aws_iam_role" "powerscale_iam_role" {
  name               = "${data.aws_caller_identity.current.account_id}-powerscale-node-runtime-role"
  assume_role_policy = data.aws_iam_policy_document.powerscale_instance_assume_role_policy.json
  description        = "powerscale IAM role for create and destroy."
}

resource "aws_iam_role_policy_attachment" "powerscale_iam_role_policy_attachment" {
  role       = aws_iam_role.powerscale_iam_role.name
  policy_arn = aws_iam_policy.powerscale_iam_instance_policy.arn
}

resource "aws_iam_instance_profile" "powerscale_iam_instance_profile" {
  name = "${data.aws_caller_identity.current.account_id}-powerscale-node-runtime-instance-profile"
  role = aws_iam_role.powerscale_iam_role.name
}

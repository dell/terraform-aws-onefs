/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/
output "powerscale_iam_policy_arn" {
  value = aws_iam_policy.powerscale_iam_instance_policy.arn
}

output "powerscale_iam_role_arn" {
  value = aws_iam_role.powerscale_iam_role.arn
}

output "powerscale_iam_role_name" {
  value = aws_iam_role.powerscale_iam_role.name
}

output "powerscale_iam_instance_profile_arn" {
  value = aws_iam_instance_profile.powerscale_iam_instance_profile.arn
}

output "powerscale_iam_instance_profile_name" {
  value = aws_iam_instance_profile.powerscale_iam_instance_profile.name
}

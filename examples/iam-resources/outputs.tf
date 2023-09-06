/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

output "powerscale_iam_policy_arn" {
  value = module.onefs_iam_resources.powerscale_iam_policy_arn
}

output "powerscale_iam_role_arn" {
  value = module.onefs_iam_resources.powerscale_iam_role_arn
}

output "powerscale_iam_role_name" {
  value = module.onefs_iam_resources.powerscale_iam_role_name
}

output "powerscale_iam_instance_profile_arn" {
  value = module.onefs_iam_resources.powerscale_iam_instance_profile_arn
}

output "powerscale_iam_instance_profile_name" {
  value = module.onefs_iam_resources.powerscale_iam_instance_profile_name
}

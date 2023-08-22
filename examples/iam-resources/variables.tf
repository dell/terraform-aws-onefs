/*

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

*/

variable "regions" {
  default     = ["*"]
  description = <<EOT
    A comma separated list of AWS region(s) where the PowerScale cluster resources are deployed.
    Eg: ["us-east-1", "us-east-2"].
    To allow all regions, provide ["*"], which is also set as the default value.
  EOT
  type        = list(string)
}

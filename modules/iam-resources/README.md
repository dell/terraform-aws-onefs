<!--

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

-->
# PowerScale OneFS Nodes Runtime IAM Resources Module

## Introduction

This folder contains a [Terraform](https://www.terraform.io/) module that defines the [IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) resources, that are used by a 
[PowerScale](https://www.delltechnologies.com/partner/en-us/partner/powerscale.htm) cluster in the [AWS](https://aws.amazon.com/) platform.

It provisions the following resources:
1. [IAM policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html)
2. [IAM Role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
3. [IAM Instance Profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)

## Definition

To ensure that the nodes which are part of a particular PowerScale cluster have the necessary permissions, you can use this module to create a new Security Group and attach the necessary rules as follows:

```hcl
module "onefs_iam_resources" {
    source = "dell/onefs/aws//modules/iam-resources"
    regions = ["us-east-1", "us-east-2", ...]
}
```

You can find the details of the security group and the rules attached to it in the [main.tf](./main.tf)

## Input Parameters

The module takes the following input parameters:

* `source`: Use this parameter to specify the URL of this module. The double slash (`//`) is intentional and required for specifying a submodule. 

* `regions`: A comma separated list of the [AWS regions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html) where PowerScale cluster(s) are going to be deployed. To allow all regions, provide ["*"].
  
  *Eg.*: `["us-west-2", "us-east-2"]`

You can find the parameters in [variables.tf](./variables.tf).

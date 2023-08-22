<!--

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

-->
# PowerScale External Security Group and its Associated Rules Module

## Introduction

This folder contains a [Terraform](https://www.terraform.io/) module that defines the External [Security Group](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html) and its associated [rules](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-rules.html), that are used by a 
[PowerScale](https://www.delltechnologies.com/partner/en-us/partner/powerscale.htm) cluster in the [AWS](https://aws.amazon.com/) platform.

## Definition

To ensure that the nodes which are part of a particular PowerScale cluster have the necessary ports open, you can use this module to create a new Security Group and attach the necessary rules as follows:

```hcl
module "external_security_group" {
    source              = "git@github.west.isilon.com:PowerScaleCloud/terraform-aws-onefs.git//modules/ext-security-group"
    cluster_id          = "#####" 
    vpc_id              = "vpc-##########"
    resource_tags       = {
    "dummy_key" = "dummy_value",
    ...
    }
    external_cidr_block = "<0-255.0-255.0-255.0-255>-<0-255.0-255.0-255.0-255>"
    gateway_hostnum     = "##" 
}
```

You can find the details of the security group and the rules attached to it in the [main.tf](./main.tf)

> **NOTE:** The rules that are attached to the external security group which is created when this module is deployed, only covers the most common use cases. For comprehensive details on the required ports which needs to be open for a PowerScale cluster, refer to the configuration specified [here](https://dl.dell.com/content/manual72850676-powerscale-onefs-9-6-0-0-security-configuration-guide.pdf#page=22?language=en-us).

## Input Parameters

The module takes the following input parameters:

* `source`: Use this parameter to specify the URL of this module. The double slash (`//`) is intentional 
  and required. Terraform uses it to specify subfolders within a Git repo (see [module 
  sources](https://www.terraform.io/docs/modules/sources.html)). 
  
  You can also use the `ref` parameter which specifies a specific Git tag in 
  this repo. That way, instead of using the latest version of this module from the `main` branch, which 
  will change every time you run Terraform, you're using a fixed version of the repo.
  
  *Eg.*: `"git@github.west.isilon.com:PowerScaleCloud/terraform-aws-onefs.git//modules/ext-security-group?ref=v0.0.1"`

  **NOTE**: Here `v0.0.1` needs to be a valid [tag](https://git-scm.com/book/en/v2/Git-Basics-Tagging) assigned with a particular Git commit.


* `cluster_id`: The cluster Id assigned to a specific PowerScale Cluster.
  
* `vpc_id`: The VPC Id used for a specific PowerScale Cluster.
  
  **NOTE**: Multiple powerscale clusters can be created within a single [AWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html).

* `external_cidr_block`: The IPv4 range within the VPC's CIDR range which has been reserved for the external subnet

* `gateway_hostnum`: The host number of the gateway in a subnet.

* `resource_tags`: The tags to be attached to the security group. The tags can be a key-value pair. The allowed values of the value in the key-value pair can be found [here](https://developer.hashicorp.com/terraform/language/expressions/types#types).

You can find the parameters in [variables.tf](./variables.tf).

## Introduction

This folder contains a [Terraform](https://www.terraform.io/) module that deploys a single node
[PowerScale](https://www.delltechnologies.com/partner/en-us/partner/powerscale.htm) cluster in the [AWS](https://aws.amazon.com/) platform. 

It provisions all the necessary resources required to deploy the cluster including the following:
   
1. [Placement Group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html)
2. [Network Interface(s)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html)
3. [EC2 Instance(s)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Instances.html)
4. [EBS Volume(s)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volumes.html)

> **NOTE**: This module only creates a single node PowerScale Cluster. However, it creates all the necessary resources required to provision a N-node cluster.

## Additional Components

The additional components which needs to be performed/deployed separately and are not included in this module are:

* [IAM Resources](../modules//iam-resources/)
* [External Security Group](../modules/ext-security-group/README.md).
* [Internal Security Group](../modules/int-security-group/README.md).
* Management Security Group(if required).
* [Post Deploy Steps](./POST_DEPLOY_STEPS.md).

So, if the number of nodes specified in the `nodes` parameter is N and the number of disks per node is specified as M, then it provisions all the necessary resources including the N OneFS node(s) i.e. the EC2 instance(s), and (N * M) disk(s) i.e. EBS volume(s). 

However, all the provisioned OneFS nodes are not added to the PowerScale Cluster as part of this module. It provisions a single node cluster, i.e. once the module is deployed only the 0th node or the node whose `serial_number` has been assigned as `SV200-930073-0000` in its [machineid template](../modules/machineid/README.md) will be added to the cluster automatically. The remaining N - 1 additional OneFS nodes need to be added separately following the steps specified [here](POST_DEPLOY_STEPS.md).

## Definition

To deploy a PowerScale cluster you can use this module to create all the dependent resources in the following way:

```hcl
module "onefs" {
  source = "git@github.west.isilon.com:PowerScaleCloud/terraform-aws-onefs.git"

  id                         = "####"
  name                       = "####"
  onefs_build                = "b.main.####"
  image_id                   = "ami-########"

  # ... (other params omitted) ...
}
```

## Input Parameters

The module takes the following input parameters:

* `region`: The region to be used to create the resources of the PowerScale Cluster. The default value is `us-east-1` or North Virginia.

* `iam_instance_profile`: The [IAM Instance Profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags_instance-profiles.html) to be attached to the OneFS nodes in the PowerScale Cluster.

* `network_id`: The VPC ID to be used to create the resources of the PowerScale Cluster.

* `id`: The ID of the PowerScale Cluster.

* `name`: The name of the PowerScale Cluster. Cluster names must begin with a letter and can contain only numbers, letters, and hyphens. If the cluster is joined to an Active Directory domain, the cluster name must be 11 characters or fewer. For more info click [here](https://www.dell.com/support/manuals/en-us/isilon-onefs/ifs_pub_9500_administration_guide_gui/set-the-cluster-name-and-contact-information?guid=guid-9d650f61-8241-4455-9469-7038216f94c4&lang=en-us)

* `nodes`: The number of nodes in the PowerScale Cluster. The default value is `3`.

* `http_tokens`: Set http_tokens to `Optional` or `Required` to modify instance metadata. Default value is `Required`.

* `availability_zone`: Availabity zone to create the PowerScale Cluster and its resources"

* `internal_subnet_id`: The ID of internal subnet of the PowerScale Cluster.

* `external_subnet_id`: The ID of external subnet of the PowerScale Cluster.

* `enable_mgmt`: A boolean flag to indicate whether to create management subnet for the PowerScale Cluster. If it's set to `true`, the management subnet will be created.

* `mgmt_subnet_id`: The ID of management subnet of the PowerScale Cluster. This is required if `enable_mgmt` is set to `true`

* `contiguous_ips`: A boolean flag to indicate whether to allocate contiguous IPv4 addresses to the external and management(if enabled) elastic network interfaces.

* `gateway_hostnum`: The host number of the gateway in a subnet. The default value is `1`.

* `smartconnect_hostnum`: The smart connect host number.  Only applicable when contiguous_ips is `true`. The default value is `4`.

* `first_external_node_hostnum`: The host number of the first external node. Only applicable when contiguous_ips is `true`. The default value is `5`.

* `first_internal_node_hostnum`: The host number of the first internal node. Only applicable when contiguous_ips is `true`. The default value is `5`.

* `security_group_external_id`: The ID of external security group, required to apply to the external interfaces in the PowerScale Cluster.

* `security_group_mgmt_id`: The ID of the management security group, required to apply to the management interfaces in the PowerScale Cluster.

* `first_mgmt_node_hostnum`: The host number of the first management node. Only applicable when contiguous_ips is `true`. The default value is `5`.

* `credentials_hashed`: A boolean flag to indicate whether the credentials are hashed or in plain text.

* `root_password`: The root user's password

* `admin_password`: The admin user's password

* `image_id`: The AMI ID of the respective build flavour(`release`/`debug`) for the given OneFS build number. 

* `dns_servers`: DNS server to route traffic. The default value is `169.254.169.253`

* `dns_domains`: The DNS domain to route traffic. The default value is `us-east-1.compute.internal`.

* `smartconnect_zone`: The FQDN to use as the DNS zone for SmartConnect.

* `timezone`: "Time zone for creating the PowerScale cluster resources in AWS.

* `resource_tags`: The tags to be attached to the AWS resources. The tags can be a key-value pair. The allowed values of the value in the key-value pair can be found [here](https://developer.hashicorp.com/terraform/language/expressions/types#types).

* `instance_type`: The type of the instance to be used for the OneFS nodes in the PowerScale cluster. For more details on the allowed values for the instance type [click here](https://aws.amazon.com/ec2/instance-types/). The default value is `m5d.large`.

* `os_disk_type`: The type of the root EBS volume to be attached to each OneFS node in the PowerScale Cluster. The default value is `gp3`. The allowed values for this parameter can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume#type)

* `data_disk_type`: The type of the secondary EBS volume(s). The default value is `gp3`. The allowed values for this parameter can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume#type)
  
* `data_disk_size`: Size of the secondary EBS voulme(s) attached to each OneFS node in the PowerScale Cluster. The default value is 16 GiB.

* `data_disks_per_node`: Number of the secondary EBS voulme(s) to be attached to each OneFS node in the PowerScale Cluster.

* `data_disk_iops`: IOPS value of the secondary EBS volume(s) attached to the OneFS nodes in the PowerScale Cluster. 

* `data_disk_throughput`: Throughput value of the secondary EBS volume(s) attached to the OneFS nodes in the PowerScale Cluster. 

* `linear_journal`: A boolean flag to set Linear journal value.

* `validate_volume_type`: A boolean flag to indicate whether to validate the input to the parameter `data_disk_type`. If set to true, the allowed value for `data_disk_type` is `gp3`.

* `placement_group_strategy`: The placement strategy for aws placement group. The default value to be used is `spread`. To check the allowed values for this parameter [click here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group#strategy)

> **NOTE:** Currently, Dell supports only the `spread` placement group strategy. It is strongly recommended to not change the value here.

* `partition_count`: The number of partitions to create in the placement group. Can only be specified when the placement_group_strategy is set to `partition`. Valid values are `1 - 7`

You can find the parameters in [variables.tf](../variables.tf).

Once this module is deployed, wait for the first OneFS node to boot up in the PowerScale Cluster.

## Post Deploy Steps

To perform the post deploy steps necessary to complete the cluster creation process, follow the steps mentioned in this [document](./POST_DEPLOY_STEPS.md).

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
  source = "dell/onefs/aws"

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

* `iam_instance_profile`: The [IAM Instance Profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_tags_instance-profiles.html) name to be attached to the OneFS nodes in the PowerScale Cluster.

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

* `first_external_node_hostnum`: The host number of the first external node. Only applicable when contiguous_ips is `true`. The default value is `5`.

* `first_internal_node_hostnum`: The host number of the first internal node. Only applicable when contiguous_ips is `true`. The default value is `5`.

* `security_group_external_id`: The ID of external security group, required to apply to the external interfaces in the PowerScale Cluster.

* `security_group_mgmt_id`: The ID of the management security group, required to apply to the management interfaces in the PowerScale Cluster.

* `first_mgmt_node_hostnum`: The host number of the first management node. Only applicable when contiguous_ips is `true`. The default value is `5`.

* `credentials_hashed`: A boolean flag to indicate whether the credentials are hashed or in plain text. The default value is `true`, indicating that the password is hashed.

* `root_password`: The root user's password. Applicable when `credentials_hashed` is set as `false`.

* `admin_password`: The admin user's password. Applicable when `credentials_hashed` is set as `false`.

* `hashed_root_passphrase`: The root user's hashed password. Applicable when `credentials_hashed` is set as `true`.

* `hashed_admin_passphrase`: The admin user's hashed password. Applicable when `credentials_hashed` is set as `true`.

* `image_id`: The AMI ID of the respective build flavour(`release`/`debug`) for the given OneFS build number. 

* `dns_servers`: DNS server to route traffic. The default value is `169.254.169.253`

* `dns_domains`: The DNS domain to route traffic. The default value is `us-east-1.compute.internal`.

* `timezone`: "Time zone for creating the PowerScale cluster resources in AWS.

* `resource_tags`: The tags to be attached to the AWS resources. The tags can be a key-value pair. The allowed values of the value in the key-value pair can be found [here](https://developer.hashicorp.com/terraform/language/expressions/types#types).

* `instance_type`: The type of the instance to be used for the OneFS nodes in the PowerScale cluster. For more details on the allowed values for the instance type [click here](https://infohub.delltechnologies.com/l/apex-file-storage-for-aws-deployment-guide/supported-cluster-configuration-6/). The default value is `m5dn.8xlarge`.

* `os_disk_type`: The type of the root EBS volume to be attached to each OneFS node in the PowerScale Cluster. The default value is `gp3`. The only allowed value is `gp3`

* `data_disk_type`: The type of the secondary EBS volume(s). The default value is `gp3`. The allowed values for this parameter can be found [here](https://infohub.delltechnologies.com/l/apex-file-storage-for-aws-deployment-guide/supported-cluster-configuration-6/)
  
* `data_disk_size`: Size of the secondary EBS voulme(s) attached to each OneFS node in the PowerScale Cluster. The allowed values for this parameter can be found [here](https://infohub.delltechnologies.com/l/apex-file-storage-for-aws-deployment-guide/supported-cluster-configuration-6/)

* `data_disks_per_node`: Number of the secondary EBS voulme(s) to be attached to each OneFS node in the PowerScale Cluster.

* `data_disk_iops`: IOPS value of the secondary EBS volume(s) attached to the OneFS nodes in the PowerScale Cluster. Applicable when `data_disk_type` is set as `gp3`.

* `data_disk_throughput`: Throughput value of the secondary EBS volume(s) attached to the OneFS nodes in the PowerScale Cluster. Applicable when `data_disk_type` is set as `gp3`.

* `placement_group_strategy`: The placement strategy for aws placement group. The default value to be used is `spread`. To check the allowed values for this parameter [click here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/placement_group#strategy)

> **NOTE:** Currently, Dell supports only the `spread` placement group strategy. It is strongly recommended to not change the value here.

* `validate_volume_type`: A boolean flag to indicate whether to validate the input to the parameter `data_disk_type`.

* `validate_data_disk_size`: A boolean flag to indicate whether to validate the input to the parameter `data_disk_size`.

* `validate_data_disks_count`: A boolean flag to indicate whether to validate the input to the parameter `data_disks_per_node`.

* `validate_instance_type`: A boolean flag to indicate whether to validate the input to the parameter `instance_type`.

* `validate_os_disk_type`: A boolean flag to indicate whether to validate the input to the parameter `os_disk_type`.

* `validate_nodes_count`: A boolean flag to indicate whether to validate the input to the parameter `nodes`.

* `validate_placement_group_strategy`: A boolean flag to indicate whether to validate the input to the parameter `placement_group_strategy`.

You can find the parameters in [variables.tf](../variables.tf).

Once this module is deployed, wait for the first OneFS node to boot up in the PowerScale Cluster.

## Post Deploy Steps

To perform the post deploy steps necessary to complete the cluster creation process, follow the steps mentioned in this [document](./POST_DEPLOY_STEPS.md).

## Persistence of State

By default, the terraform module is configured to use the [local](https://developer.hashicorp.com/terraform/language/settings/backends/local) directory of the respective modules for its state persistence. Hence, the [terraform state](https://developer.hashicorp.com/terraform/language/state) will be stored as files in the respective modules` directories.
In order to use any of the other available state persistence options provided by terraform, you need to add a [backend block](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#using-a-backend-block) to the respective module's main.tf with the details of the respective backend configuration that you would like to use.
> **NOTE**: It's strongly recommended that if you are changing the backend configuration, update that in the terraform configuration file from where you are calling this module.
For more information on the available backend store options provided by terraform [click here](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#available-backends).

## Terraform Errors

If an error appears during the terraform apply stage, one of the below actions can be taken
* `terraform apply` : Run the `terraform apply` command to retry
* `terraform destroy` : To destroy all resources created from the `terraform apply` command

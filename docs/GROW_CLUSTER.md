<!--

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

-->
# Steps to Grow a PowerScale Cluster

## Pre-Requisites:

The following prerequisites must be met in order to grow a powerscale cluster in AWS.  If you are using the example files provided in this documentation you will need your subscription id in order to create the required resources in your subscription:

[PowerScale Cluster is deployed](POWERSCALE_CLUSTER.md) 

## Perform Grow Cluster using Terraform

To deploy all the necessary resources for growing a PowerScale cluster, navigate to the appropriate directory from where the PowerScale Cluster was deployed if the state file is in your local configuration or import the state file from its corresponding remote store and run the following command:

```shell
terraform apply -auto-approve -var="nodes=<replace-updated-number-of-nodes>"
```

## Get Details of newly deployed resources

To complete the process to grow a PowerScale cluster, you need to fetch the following details from the terraform output:

1. The primary private IP address of the external network interface attached to each of the newly added OneFS nodes.
2. The higest private IP address assigned among the internal network interfaces attached to the OneFS nodes.
3. The lowest private IP address assigned among the internal network interfaces attached to the OneFS nodes.

You can get them by running the following command:

```shell
terraform output
```

If you are using the [example module](../examples/), you will find the required external IP address(es) in the `additional_nodes_external_ip_addresses`, `internal_network_high_ip` and `internal_network_low_ip` respectively.

<details>
<summary>Click to expand sample command execution</summary>

Command:
```shell
terraform output
```

Response:
```textmate

additional_nodes_external_ip_addresses = [
  "100.93.143.196",
  "100.93.143.200",
  "100.93.143.198",
  "100.93.143.197",
]
cluster_id = "fluent-vulture"
first_node_external_ip_address = "100.93.143.205"
internal_network_high_ip = "100.93.143.57"
internal_network_low_ip = "100.93.143.53"
```
</details>

## SSH to the cluster

SSH into any one of the OneFS nodes which were already added to the PowerScale Cluster before the grow cluster operation was initiated.

You can use the AWS Serial Console for the same or use the private IP address of the external network interface attached to the node you chose to SSH into:

```shell
ssh root@<onefs node's external ip address>
```

Once connected check the cluster health and ensure that the cluster and node health report is `OK`:

```shell
isi status
```

### Validate cluster internal networks configuration

We need to ensure that the range of the internal network interface's private ip addresses(as obtained [above](#get-details-of-newly-deployed-resources)) is correctly configured in the cluster's `internal-networks`.

To view the existing range of ip addresses configured use the following command:

```shell
isi cluster internal-networks view
```

The internal network interface's private ip address should be covered by the range set for `Int-a IP Addresses` in 
`Primary Network Configuration`. If the currently set range includes the higest and lowest IP address among the private IP addresses of the internal network interfaces that are attached to the OneFS nodes after the grow operation was complete, the details of which were obtained [above](#get-details-of-newly-deployed-resources), then we are good. Otherwise, we need to update the range 

<details>
<summary>Click to expand sample execution</summary>

```shell
isi cluster internal-networks view
```
Response:
```textmate

Primary Network Configuration
-----------------------------
 Int-a IP Addresses: 100.93.144.53-100.93.144.56
       Int-a Status: enabled
Int-a Prefix Length: 28
          Int-a MTU: 9001
       Int-a Fabric: Ethernet

Failover Network Configuration
------------------------------
   Int-b IP Addresses: -
      Failover Status: -
  Int-b Prefix Length: -
            Int-b MTU: -
         Int-b Fabric: -
Failover IP Addresses: -

```
</details>

To update the range, use the following command with the new range of highest and lowest IP addresses of the internal network interfaces:

```shell
isi cluster internal-networks modify --int-a-ip-addresses <low-ip-address>-<high-ip-address>
```

| Key Name         | Description                                                                                                  | 
| :---:            | :---:                                                                                                        |
| low-ip-address   | Lowest internal network interface's IP address as noted [above](#get-details-of-newly-deployed-resources)  |
| high-ip-address  | Highest internal network interface's IP address as noted [above](#get-details-of-newly-deployed-resources) |

### Add newly added instance's external ip address to the groupnet0.subnet0.pool0 network pool

First check if the newly added OneFS nodes are ready to join the cluster and is showing `available` run the following command:

```shell
isi devices node list
```

<details>
<summary>Click to expand sample execution</summary>

```shell
 isi devices node list
```
Response:
```textmate
Serial Number     Product                                          Version      Status
-----------------------------------------------------------------------------------------
SV200-930073-0004 AWS-m5d.large-Cloud-Single-8192MB-1x1GE-80GB SSD B_9_6_0_004R available
-----------------------------------------------------------------------------------------
Total: 2

```
</details>
<br>

> **NOTE**: The `Serial Number` of the nodes which are `available` to join the cluster should be noted down as it will be used in the next section to add the node to the PowerScale cluster.

To add its external interface's private ip address to the groupnet0.subnet0.pool0 network pool as identified [above](#get-details-of-newly-deployed-resources) use the following command:

```shell
isi network pools modify groupnet0.subnet0.pool0 --add-ranges <instance external ip>-<instance external ip>
```

Repeat the above command for each of the newly added OneFS nodes` external ip address noted [above](#get-details-of-newly-deployed-resources) by using the commands specified [here](#add-newly-added-instances-external-ip-address-to-the-groupnet0subnet0pool0-network-pool).

### Join Newly Added Nodes

Then join the node to the cluster

```shell
isi device node add <serial number> --async
```

| Name | Description |
| ---- | ----------- |
| serial number | the serial number of the instance |

Then wait for the node to join by watching the cluster and node status

    isi status

Wait for the node to appear in the output and report a status of OK and the cluster to return to a status of OK.

You need to add all the newly added nodes one by one using the commands specified [here](#join-additional-nodes).

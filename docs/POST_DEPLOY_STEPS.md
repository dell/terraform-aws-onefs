<!--

        Copyright (c) 2023 Dell, Inc or its subsidiaries.

        This Source Code Form is subject to the terms of the Mozilla Public
        License, v. 2.0. If a copy of the MPL was not distributed with this
        file, You can obtain one at https://mozilla.org/MPL/2.0/.

-->
# Post Deploy Steps

## Pre-Requisites:

The following prerequisites must be met in order to add the additional node(s) in a powerscale cluster in AWS.  If you are using the example files provided in this documentation you will need your subscription id in order to create the required resources in your subscription:

[PowerScale Cluster is deployed](POWERSCALE_CLUSTER.md) 

## Get Details of deployed OneFS module

Run the following command to get the terraform output and note down all the parameters listed in the output.

```shell
terraform output
```

If you are using the [example module](../examples/), you will find the necessary values in the parameters `cluster_id`, `first_node_external_ip_address`, `first_node_instance_id`, `additional_nodes_external_ip_addresses`, `internal_network_low_ip` and `internal_network_high_ip`

<details>
<summary>Click to expand sample execution</summary>

```shell
 terraform output
```

Response:
```textmate
additional_nodes_external_ip_addresses = [
  "100.93.145.36",
  "100.93.145.46",
  "100.93.145.45",
]
cluster_id = "above-bonefish"
first_node_external_ip_address = "100.93.145.44"
first_node_instance_id = "i-010e0ee92d88d3c34"
internal_network_high_ip = "100.93.144.24"
internal_network_low_ip = "100.93.144.21"
region = "us-east-1"
```
</details>
<br>

Alternatively, you can use the following commands to fetch the parameters individually:

```shell
terraform output <output-parameter-name>
```
<details>
<summary>Click to expand sample execution</summary>

Command:
```shell
terraform output additional_nodes_external_ip_addresses
```

Response:
```textmate
[
  "100.93.143.201",
  "100.93.143.200",
  "100.93.143.202",
]
```

Command:
```shell
terraform output cluster_id
```

Response:
```textmate
"giving-lark"
```

Command:
```shell
terraform output first_node_external_ip_address 
```

Response:
```textmate
"100.93.143.197"
```

Command:
```shell
terraform output first_node_instance_id 
```

Response:
```textmate
"i-0deae5fc05cbe3731"
```

Command:
```shell
terraform output internal_network_high_ip  
```

Response:
```textmate
"100.93.143.56"
```

Command:
```shell
terraform output internal_network_low_ip  
```

Response:
```textmate
"100.93.143.53"
```

Command:
```shell
terraform output region  
```

Response:
```textmate
"us-east-1"
```
</details>


## SSH to the cluster

For the first node to boot up and get added to the PowerScale Cluster, it does take a fair amount of time. We need to wait until the first node boots up and the Auto Cluster Setup adds the first node to the cluster, this will take place automatically as we can't proceed with the rest of the steps till that process is complete. 

You can use the Private IP address of the External Network Interface of the first node or the lowest IP address, as obtained [above](#get-details-of-deployed-onefs-module) to SSH into the first node. 

```shell
ssh root@<first instance's external ip address>
```

| Name | Description |
| ---- | ----------- |
| first instance external ip address | The ip address of the node where hal_is_first_node is set to true in the machineid.json file. |

Alternatively, if you have [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed in your environment, using that you can connect to the first node using the [AWS EC2 Serial-Console](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-serial-console.html).

You can also use the following shell commands to SSH into the first node.

Load public key to connect to the first node using EC2 Serial-Console:

```shell
INSTANCE_ID=$(terraform output first_node_instance_id)
AWS_REGION=$(terraform output region)

aws ec2-instance-connect send-serial-console-ssh-public-key \
    --instance-id $INSTANCE_ID \
    --serial-port 0 \
    --ssh-public-key file://~/.ssh/id_rsa.pub \
    --region $AWS_REGION
```

SSH into the first node using EC2 Serial Console:

```shell
ssh $INSTANCE_ID.port0@serial-console.ec2-instance-connect.$AWS_REGION.aws
```

> **NOTE**: OneFS can take several minutes to startup the first time.  If you get an error when connecting to and authenticating with OneFS. Please wait a few more minutes and then try again.


### Wait for first instance to complete boot

Once you can connect you will be prompted for the password, use the same password that you have provided while deploying the terraform module for the particular user you are logging in as in the input variable.

Once connected check the cluster health until cluster and node health report shows `OK`:

```shell
isi status
```

NOTE: This command may fail in a variety of ways as the cluster is booting which may take several minutes. Please wait for some time and try again.

Then check that the authorization system is up by running:

```shell
isi auth user list
```

> **NOTE**: This command may fail in a variety of ways as the cluster is booting please wait X minutes before contacting support.

### Update cluster internal networks configuration

We need to ensure that the range of the internal network interface's private ip addresses range(as obtained [above](#get-details-of-deployed-onefs-module)) is correctly configured in the cluster's `internal-networks`.

To view the existing range of ip addresses configured using the command:

```shell
isi cluster internal-networks view
```

The internal network interface's private ip address should be covered by the range set for `Int-a IP Addresses` in 
`Primary Network Configuration`.

<details>
<summary>Click to expand sample execution</summary>

```shell
isi cluster internal-networks view
```
Response:
```textmate

Primary Network Configuration
-----------------------------
 Int-a IP Addresses: 100.93.144.66-100.93.144.66
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

If the IP address range of the internal network interface is not covered by the currently configured IP range, we need to update the IP addresses of the internal network interface attached to the OneFS nodes, as noted [above](#get-details-of-deployed-onefs-module). <br>

Use the following command to update internal-networks IP address range:

```shell
isi cluster internal-networks modify --int-a-ip-addresses <low-ip-address>-<high-ip-address>
```

| Key Name         | Description                                                                                                  | 
| :---:            | :---:                                                                                                        |
| low-ip-address   | Lowest internal network interface's IP addresses as noted [above](#get-details-of-deployed-onefs-module)  |
| high-ip-address  | Highest internal network interface's IP addresses as noted [above](#get-details-of-deployed-onefs-module) |


Alternatively, you can also update it with the entire host IP address range of the internal subnet, to avoid updating the `internal-networks` IP address range after subsequent operations such as grow cluster.

To find out the CIDR range of the internal subnet, use the following command:

```shell
aws ec2 describe-subnets \
    --subnet-ids "subnet-********" # Replace with internal Subnet ID \
    --query "Subnets[*].CidrBlock"
```

<details>
<summary>Click to expand detailed explanation</summary>

Let's say you have a CIDR notation like `192.168.1.0/24` for a subnet.

You can calculate the usable host IP address range for that subnet by using the following steps:

1. **Extract Network Address and Prefix Length:**
   - Split the CIDR notation into two parts: the IP address and the prefix length.
   - For example, in `192.168.1.0/24 ` the IP address is `192.168.1.0` and the prefix length is `24`.
2. **Convert IP Address to Binary:**
   - Convert each decimal part of the IP address into its binary equivalent.
   - For `192.168.1.0` the binary parts are: `11000000.10101000.00000001.00000000`.
3. **Calculate Subnet Mask:**
   - The prefix length (**e.g**., `/24`) indicates how many bits are part of the network portion of the address. The remaining bits are for host addresses.
   - For a /24 prefix length, the subnet mask is `255.255.255.0` in decimal or `11111111.11111111.11111111.00000000` in binary.
4. **Calculate Network Address:**
   - Perform a bitwise AND operation between the IP address in binary and the subnet mask in binary.
   - For `192.168.1.0/24` the network address is: `11000000.10101000.00000001.00000000` (IP) AND `11111111.11111111.11111111.00000000` (Mask) = 192.168.1.0.
5. **Calculate Broadcast Address:**
   - The broadcast address is the last address in the subnet and is calculated by setting all host bits to 1 in the network address.
   - For a `/24` prefix length, the broadcast address is: `192.168.1.255`.
6. **Calculate First and Last Usable Host Addresses:**
   - The first usable host address is the network address + 1, and the last usable host address is the broadcast address - 1.
   - For `192.168.1.0/24`, the first usable host is `192.168.1.1`, and the last usable host is `192.168.1.254`.

Hence, the IPv4 address range for the CIDR notation `192.168.1.0/24` is `192.168.1.0` - `192.168.1.255`, with **usable host addresses** ranging from **`192.168.1.1` to `192.168.1.254`**.

So, to update the internal-networks with the entire host address range of the internal subnet, we can use the following command:

```shell
isi cluster internal-networks modify --int-a-ip-addresses 100.93.144.65-100.93.144.78
```
</details>

### Add instance's external ip address to the groupnet0.subnet0.pool0 network pool

To check if the rest of the N-1 nodes are ready to join the cluster and is showing `available` run the following command:

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
SV200-930073-0001 AWS-m5d.large-Cloud-Single-8192MB-1x1GE-80GB SSD B_9_6_0_004R available
SV200-930073-0002 AWS-m5d.large-Cloud-Single-8192MB-1x1GE-80GB SSD B_9_6_0_004R available
SV200-930073-0003 AWS-m5d.large-Cloud-Single-8192MB-1x1GE-80GB SSD B_9_6_0_004R available
-----------------------------------------------------------------------------------------
Total: 3

```
</details>
<br>

> **NOTE**: The `Serial Number` of the nodes which are `available` to join the cluster should be noted down as it will be used in the next section to add the node to the PowerScale cluster.
 
Before adding the instances, first add its external interface's private ip address to the groupnet0.subnet0.pool0 network pool as identified [above](#get-details-of-deployed-onefs-module)

```shell
isi network pools modify groupnet0.subnet0.pool0 --add-ranges <instance external ip>-<instance external ip> --force
```

Repeat the above command for each of the external ip address noted [above](#get-details-of-deployed-onefs-module)

| Name | Description |
| ---- | ----------- |
| instance external ip | The external ip address assigned to the external nic assigned to the instance. |

### Join Additional Nodes

Then join the node to the cluster

    isi device node add <serial number> --async

| Name | Description |
| ---- | ----------- |
| serial number | the serial number of the instance |

Then wait for the node to join by watching the cluster and node status

    isi status

Wait for the node to appear in the output and report a status of OK and the cluster to return to a status of OK.

You need to add all the additional nodes one by one using the commands specified [here](#join-additional-nodes).

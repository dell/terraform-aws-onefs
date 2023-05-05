# terraform-aws-onefs

Core Terraform module for deploying PowerScale clusters in AWS.

## Usage

This github repository is intended to be used as a git submodule of `terraform-aws-onefs-lab` which includes test and deployment logic for different AWS deployment flavors (Aurora, Borealis).

For deploying sandbox environments of various flavors, please refer to
the [Sandboxes section of the `terraform-aws-onefs-lab`'s readme](https://github.west.isilon.com/PowerScaleCloud/terraform-aws-onefs-lab#sandboxes)

## Testing

To test changes made to Terraform modules contained in this repo, the changes should be tested as a change to the subcommit hash of the [terraform-aws-onefs-lab](https://github.west.isilon.com/PowerScaleCloud/terraform-aws-onefs-lab) repo.

For more details please refer to the [terraform-aws-onefs-lab README](https://github.west.isilon.com/PowerScaleCloud/terraform-aws-onefs-lab#test-development) and Confluence page [AWS: Testing terraform-aws-onefs](https://confluence.cec.lab.emc.com/display/ISI/AWS%3A+Testing+terraform-aws-onefs)
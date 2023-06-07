variable "id" {
  default     = null
  description = "The cluster id to be used as a tag in the security group"
}

variable "resource_tags" {
  type = map(string)
  default = {
  }
  description = "The Tags to be associated with the Security Group"
}

variable "network_id" {
  description = "The VPC id to be used for creating the security group"
}


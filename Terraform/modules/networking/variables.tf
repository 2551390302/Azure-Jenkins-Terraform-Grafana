variable "vnet_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "address_space" { type = list(string) }
variable "aks_subnet_prefix" { type = list(string) }
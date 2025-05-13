variable "resource_group_name" {}
variable "resource_group_location" {}
variable "cluster_name" {}
variable "dns_prefix" {}
variable "vm_size" {
  default = "Standard_B2s"
}
variable "node_count" {
  default = 2
}
variable "username" {
  default = "azureadmin"
}
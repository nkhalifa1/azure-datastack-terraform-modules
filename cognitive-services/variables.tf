variable "rg_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location of the resource group"
}

variable "prefix" {
  type        = string
  description = "Prefix for the module name"
}

variable "postfix" {
  type        = string
  description = "Postfix for the module name"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the vnet that should be linked to the DNS zone"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet from which private IP addresses will be allocated for this Private Endpoint"
}

variable "kind" {
  type        = string
  description = "Specifies the type of Cognitive Service Account that should be created"
}
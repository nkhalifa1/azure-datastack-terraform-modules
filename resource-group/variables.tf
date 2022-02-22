variable "name" {
  type        = string
  default     = "syn-terraform-demo01"
  description = "Resource group name"
}

variable "location" {
  type        = string
  default     = "North Europe"
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
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for the Virtual Network"
  type        = string
}

variable "vnet_name" {
  description = "Name tag for the VNet"
  type        = string
  default     = "CI/CD VNet"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "private_app_subnet_1_cidr" {
  description = "CIDR block for private app subnet 1"
  type        = string
}

variable "private_app_subnet_2_cidr" {
  description = "CIDR block for private app subnet 2"
  type        = string
}

variable "private_db_subnet_1_cidr" {
  description = "CIDR block for private DB subnet 1"
  type        = string
}

variable "private_db_subnet_2_cidr" {
  description = "CIDR block for private DB subnet 2"
  type        = string
}

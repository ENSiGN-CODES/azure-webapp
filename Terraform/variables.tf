#-------------General-------------------#
variable "location" {
  description = "Azure region to deploy resources (e.g. westeurope, eastus)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "monty-hall-rg"
}

#-------------VNet (equivalent of VPC)-------------------#
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

#-------------VM (equivalent of EC2)-------------------#
variable "vm_size" {
  description = "Azure VM size (equivalent of EC2 instance type)"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key content (injected via GitHub Secret as TF_VAR_ssh_public_key)"
  type        = string
  sensitive   = true
}

#-------------Load Balancer (equivalent of ALB)-------------------#
variable "lb_name" {
  description = "Name of the Azure Load Balancer"
  type        = string
  default     = "monty-hall-lb"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block of the VNet (used for DB NSG rules)"
  type        = string
}

# Subnet IDs for NSG associations
variable "public_subnet_1_id" {
  description = "ID of public subnet 1"
  type        = string
}

variable "public_subnet_2_id" {
  description = "ID of public subnet 2"
  type        = string
}

variable "private_app_subnet_1_id" {
  description = "ID of private app subnet 1"
  type        = string
}

variable "private_app_subnet_2_id" {
  description = "ID of private app subnet 2"
  type        = string
}

variable "private_db_subnet_1_id" {
  description = "ID of private DB subnet 1"
  type        = string
}

variable "private_db_subnet_2_id" {
  description = "ID of private DB subnet 2"
  type        = string
}

# Azure NSGs use CIDR ranges for source rules (not SG references like AWS)
# so we pass the CIDRs to scope traffic correctly
variable "public_subnet_1_cidr_range" {
  description = "CIDR range of public subnet 1 (used to restrict instance NSG to LB/bastion traffic)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr_range" {
  description = "CIDR range of public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

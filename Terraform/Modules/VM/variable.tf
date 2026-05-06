variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size (equivalent of EC2 instance type)"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "bastion_nsg_id" {
  description = "NSG ID for the Bastion VM"
  type        = string
}

variable "instance_nsg_id" {
  description = "NSG ID for the app VMs"
  type        = string
}

variable "public_subnet_1_id" {
  description = "ID of public subnet 1 (for bastion)"
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

variable "lb_backend_pool_id" {
  description = "ID of the LB backend address pool to register app VMs"
  type        = string
}

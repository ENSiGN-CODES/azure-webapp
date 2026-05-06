variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "lb_name" {
  description = "Name of the Azure Load Balancer"
  type        = string
  default     = "monty-hall-lb"
}

variable "public_subnet_1_id" {
  description = "ID of public subnet 1 (reserved for future internal LB placement if needed)"
  type        = string
}

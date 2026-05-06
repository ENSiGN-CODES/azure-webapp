output "lb_nsg_id" {
  description = "ID of the Load Balancer NSG (equivalent of ALBSG)"
  value       = azurerm_network_security_group.lb_nsg.id
}

output "bastion_nsg_id" {
  description = "ID of the Bastion NSG (equivalent of BastionSG)"
  value       = azurerm_network_security_group.bastion_nsg.id
}

output "instance_nsg_id" {
  description = "ID of the application instance NSG (equivalent of InstanceSG)"
  value       = azurerm_network_security_group.instance_nsg.id
}

output "db_nsg_id" {
  description = "ID of the DB NSG (equivalent of RDSSG + ElastiCacheSG)"
  value       = azurerm_network_security_group.db_nsg.id
}

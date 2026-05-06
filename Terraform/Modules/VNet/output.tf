output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "public_subnet_1_id" {
  description = "ID of public subnet 1"
  value       = azurerm_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2"
  value       = azurerm_subnet.public_subnet_2.id
}

output "private_app_subnet_1_id" {
  description = "ID of private app subnet 1"
  value       = azurerm_subnet.private_app_subnet_1.id
}

output "private_app_subnet_2_id" {
  description = "ID of private app subnet 2"
  value       = azurerm_subnet.private_app_subnet_2.id
}

output "private_db_subnet_1_id" {
  description = "ID of private DB subnet 1"
  value       = azurerm_subnet.private_db_subnet_1.id
}

output "private_db_subnet_2_id" {
  description = "ID of private DB subnet 2"
  value       = azurerm_subnet.private_db_subnet_2.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = azurerm_public_ip.nat_pip.ip_address
}

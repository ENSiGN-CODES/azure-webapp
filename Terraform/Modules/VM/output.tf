output "bastion_public_ip" {
  description = "Public IP of the Bastion VM"
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "app_vm_1_id" {
  description = "Resource ID of app VM 1"
  value       = azurerm_linux_virtual_machine.app_vm_1.id
}

output "app_vm_2_id" {
  description = "Resource ID of app VM 2"
  value       = azurerm_linux_virtual_machine.app_vm_2.id
}

output "app_vm_1_private_ip" {
  description = "Private IP of app VM 1"
  value       = azurerm_network_interface.app_nic_1.private_ip_address
}

output "app_vm_2_private_ip" {
  description = "Private IP of app VM 2"
  value       = azurerm_network_interface.app_nic_2.private_ip_address
}

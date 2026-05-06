output "lb_public_ip" {
  description = "Public IP of the Load Balancer — paste into browser to reach the app"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "lb_id" {
  description = "Resource ID of the Load Balancer"
  value       = azurerm_lb.lb.id
}

output "backend_pool_id" {
  description = "Resource ID of the LB backend address pool (VMs register against this)"
  value       = azurerm_lb_backend_address_pool.backend_pool.id
}

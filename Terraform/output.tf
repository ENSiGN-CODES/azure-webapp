output "lb_public_ip" {
  description = "Access your app via this IP (equivalent of ALB DNS name)"
  value       = module.lb.lb_public_ip
}

output "bastion_public_ip" {
  description = "Public IP to SSH into the Bastion host"
  value       = module.vm.bastion_public_ip
}

output "vnet_id" {
  description = "ID of the Virtual Network (equivalent of VPC ID)"
  value       = module.vnet.vnet_id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.vnet.nat_gateway_public_ip
}

output "app_vm_1_private_ip" {
  description = "Private IP of app VM 1 (used by Ansible inventory)"
  value       = module.vm.app_vm_1_private_ip
}

output "app_vm_2_private_ip" {
  description = "Private IP of app VM 2 (used by Ansible inventory)"
  value       = module.vm.app_vm_2_private_ip
}

#-------------General-------------------#
location            = "westeurope"
resource_group_name = "monty-hall-rg"

#-------------VNet (equivalent of VPC)-------------------#
vnet_cidr                 = "10.0.0.0/16"
vnet_name                 = "CI/CD VNet"
public_subnet_1_cidr      = "10.0.1.0/24"
public_subnet_2_cidr      = "10.0.2.0/24"
private_app_subnet_1_cidr = "10.0.3.0/24"
private_app_subnet_2_cidr = "10.0.4.0/24"
private_db_subnet_1_cidr  = "10.0.5.0/24"
private_db_subnet_2_cidr  = "10.0.6.0/24"

#-------------VM (equivalent of EC2)-------------------#
vm_size        = "Standard_B1s"   # ~t3.micro equivalent, free-tier eligible
admin_username = "azureuser"
# ssh_public_key is passed via GitHub Secret: TF_VAR_ssh_public_key

#-------------Load Balancer (equivalent of ALB)-------------------#
lb_name = "monty-hall-lb"

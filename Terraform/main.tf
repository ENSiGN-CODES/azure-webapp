#---------------- Resource Group ---------------------#
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

#---------------- VNet Module (equivalent of AWS VPC Module) ---------------------#
module "vnet" {
  source = "./Modules/VNet"

  resource_group_name       = azurerm_resource_group.rg.name
  location                  = var.location
  vnet_cidr                 = var.vnet_cidr
  vnet_name                 = var.vnet_name
  public_subnet_1_cidr      = var.public_subnet_1_cidr
  public_subnet_2_cidr      = var.public_subnet_2_cidr
  private_app_subnet_1_cidr = var.private_app_subnet_1_cidr
  private_app_subnet_2_cidr = var.private_app_subnet_2_cidr
  private_db_subnet_1_cidr  = var.private_db_subnet_1_cidr
  private_db_subnet_2_cidr  = var.private_db_subnet_2_cidr
}

#---------------- NSG Module (equivalent of AWS SG Module) ---------------------#
module "nsg" {
  source = "./Modules/NSG"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_cidr           = var.vnet_cidr

  public_subnet_1_id      = module.vnet.public_subnet_1_id
  public_subnet_2_id      = module.vnet.public_subnet_2_id
  private_app_subnet_1_id = module.vnet.private_app_subnet_1_id
  private_app_subnet_2_id = module.vnet.private_app_subnet_2_id
  private_db_subnet_1_id  = module.vnet.private_db_subnet_1_id
  private_db_subnet_2_id  = module.vnet.private_db_subnet_2_id

  # Pass subnet CIDRs so instance NSG can restrict traffic to LB/bastion subnets only
  public_subnet_1_cidr_range = var.public_subnet_1_cidr
  public_subnet_2_cidr_range = var.public_subnet_2_cidr
}

#---------------- VM Module (equivalent of AWS EC2 Module) ---------------------#
module "vm" {
  source = "./Modules/VM"

  resource_group_name     = azurerm_resource_group.rg.name
  location                = var.location
  vm_size                 = var.vm_size
  admin_username          = var.admin_username
  ssh_public_key          = var.ssh_public_key
  bastion_nsg_id          = module.nsg.bastion_nsg_id
  instance_nsg_id         = module.nsg.instance_nsg_id
  public_subnet_1_id      = module.vnet.public_subnet_1_id
  private_app_subnet_1_id = module.vnet.private_app_subnet_1_id
  private_app_subnet_2_id = module.vnet.private_app_subnet_2_id
  lb_backend_pool_id      = module.lb.backend_pool_id
}

#---------------- LB Module (equivalent of AWS ALB Module) ---------------------#
module "lb" {
  source = "./Modules/LB"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  lb_name             = var.lb_name
  public_subnet_1_id  = module.vnet.public_subnet_1_id
}

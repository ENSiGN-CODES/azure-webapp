#-------------Virtual Network (equivalent of AWS VPC)----------------------#
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Name = var.vnet_name
  }
}

#-------------Public Subnets (ALB + Bastion tier)-------------------#
resource "azurerm_subnet" "public_subnet_1" {
  name                 = "public-subnet-1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_1_cidr]
}

resource "azurerm_subnet" "public_subnet_2" {
  name                 = "public-subnet-2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_2_cidr]
}

#-------------Private App Subnets-------------------#
resource "azurerm_subnet" "private_app_subnet_1" {
  name                 = "private-app-subnet-1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_app_subnet_1_cidr]
}

resource "azurerm_subnet" "private_app_subnet_2" {
  name                 = "private-app-subnet-2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_app_subnet_2_cidr]
}

#-------------Private DB Subnets (reserved for future DB tier)-------------------#
resource "azurerm_subnet" "private_db_subnet_1" {
  name                 = "private-db-subnet-1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_db_subnet_1_cidr]
}

resource "azurerm_subnet" "private_db_subnet_2" {
  name                 = "private-db-subnet-2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_db_subnet_2_cidr]
}

#-------------NAT Gateway Public IP (equivalent of AWS Elastic IP for NAT)-------------------#
resource "azurerm_public_ip" "nat_pip" {
  name                = "nat-gateway-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = "NAT Gateway Public IP"
  }
}

#-------------NAT Gateway (equivalent of AWS NAT Gateway)-------------------#
# Placed in public_subnet_1 to give private subnets outbound internet access (for Docker pulls)
resource "azurerm_nat_gateway" "nat_gw" {
  name                = "az1-nat-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"

  tags = {
    Name = "AZ1 NAT"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

#-------------Associate NAT Gateway with private subnets-------------------#
resource "azurerm_subnet_nat_gateway_association" "private_app_1" {
  subnet_id      = azurerm_subnet.private_app_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

resource "azurerm_subnet_nat_gateway_association" "private_app_2" {
  subnet_id      = azurerm_subnet.private_app_subnet_2.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

resource "azurerm_subnet_nat_gateway_association" "private_db_1" {
  subnet_id      = azurerm_subnet.private_db_subnet_1.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

resource "azurerm_subnet_nat_gateway_association" "private_db_2" {
  subnet_id      = azurerm_subnet.private_db_subnet_2.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}
# Note: In Azure, VNets have built-in routing. There is no need to create a separate
# Internet Gateway or route tables — internet routing for public subnets is handled
# automatically; NAT Gateway handles outbound for private subnets.

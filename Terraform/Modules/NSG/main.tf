#-------------------------- NSG For Load Balancer (equivalent of ALBSG) --------------------------#
resource "azurerm_network_security_group" "lb_nsg" {
  name                = "lb-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTP from all (public internet)"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#-------------------------- NSG For Bastion Host (equivalent of BastionSG) --------------------------#
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "bastion-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-ssh-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow SSH from all (management access)"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#-------------------------- NSG For App Instances (equivalent of InstanceSG) --------------------------#
# Allow HTTP only from the LB subnet + SSH only from the Bastion subnet
resource "azurerm_network_security_group" "instance_nsg" {
  name                = "instance-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-http-from-lb-subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.public_subnet_1_cidr_range
    destination_address_prefix = "*"
    description                = "Allow HTTP from LB public subnet only"
  }

  security_rule {
    name                       = "allow-http-from-lb-subnet-2"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.public_subnet_2_cidr_range
    destination_address_prefix = "*"
    description                = "Allow HTTP from LB public subnet 2"
  }

  security_rule {
    name                       = "allow-ssh-from-bastion"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.public_subnet_1_cidr_range
    destination_address_prefix = "*"
    description                = "Allow SSH from bastion subnet only — no direct internet"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#-------------------------- NSG For DB Subnet (equivalent of RDSSG + ElastiCacheSG) --------------------------#
resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-mysql-from-vnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
    description                = "Allow MySQL from VNet only (internal)"
  }

  security_rule {
    name                       = "allow-redis-from-vnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379"
    source_address_prefix      = var.vnet_cidr
    destination_address_prefix = "*"
    description                = "Allow Redis/ElastiCache from VNet only"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#-------------------------- Associate NSGs with Subnets --------------------------#
resource "azurerm_subnet_network_security_group_association" "public_1" {
  subnet_id                 = var.public_subnet_1_id
  network_security_group_id = azurerm_network_security_group.lb_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "public_2" {
  subnet_id                 = var.public_subnet_2_id
  network_security_group_id = azurerm_network_security_group.lb_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_app_1" {
  subnet_id                 = var.private_app_subnet_1_id
  network_security_group_id = azurerm_network_security_group.instance_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_app_2" {
  subnet_id                 = var.private_app_subnet_2_id
  network_security_group_id = azurerm_network_security_group.instance_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_db_1" {
  subnet_id                 = var.private_db_subnet_1_id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_db_2" {
  subnet_id                 = var.private_db_subnet_2_id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

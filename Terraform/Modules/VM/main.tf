#-------------Bastion Host Public IP-------------------#
resource "azurerm_public_ip" "bastion_pip" {
  name                = "bastion-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = "Bastion Public IP"
  }
}

#-------------Bastion NIC (with public IP)-------------------#
resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "bastion-nic-config"
    subnet_id                     = var.public_subnet_1_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "bastion_nic_nsg" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = var.bastion_nsg_id
}

#-------------Bastion Host VM (equivalent of aws_instance bastion_instance)-------------------#
resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                  = "bastion-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 LTS — equivalent of Amazon Linux 2 AMI
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Name = "Bastion"
  }
}

#-------------App Instance 1 NIC (private only — no public IP)-------------------#
resource "azurerm_network_interface" "app_nic_1" {
  name                = "app-nic-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "app-nic-1-config"
    subnet_id                     = var.private_app_subnet_1_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "app_nic_1_nsg" {
  network_interface_id      = azurerm_network_interface.app_nic_1.id
  network_security_group_id = var.instance_nsg_id
}

#-------------App Instance 1 VM (equivalent of aws_instance application_instance_1)-------------------#
resource "azurerm_linux_virtual_machine" "app_vm_1" {
  name                  = "app-vm-1"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.app_nic_1.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Name = "application_vm_1"
  }
}

#-------------App Instance 2 NIC (private only — no public IP)-------------------#
resource "azurerm_network_interface" "app_nic_2" {
  name                = "app-nic-2"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "app-nic-2-config"
    subnet_id                     = var.private_app_subnet_2_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "app_nic_2_nsg" {
  network_interface_id      = azurerm_network_interface.app_nic_2.id
  network_security_group_id = var.instance_nsg_id
}

#-------------App Instance 2 VM (equivalent of aws_instance application_instance_2 with user_data)-------------------#
resource "azurerm_linux_virtual_machine" "app_vm_2" {
  name                  = "app-vm-2"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.app_nic_2.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Equivalent of EC2 user_data — bootstraps Apache for initial LB health-check pass
  # while Ansible later replaces it with the Docker container
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello World from $(hostname -f)<br> This is The 2nd VM Instance</h1>" > /var/www/html/index.html
    EOF
  )

  tags = {
    Name = "application_vm_2"
  }
}

#-------------Associate App VMs with LB Backend Pool-------------------#
resource "azurerm_network_interface_backend_address_pool_association" "app_vm_1_lb" {
  network_interface_id    = azurerm_network_interface.app_nic_1.id
  ip_configuration_name   = "app-nic-1-config"
  backend_address_pool_id = var.lb_backend_pool_id
}

resource "azurerm_network_interface_backend_address_pool_association" "app_vm_2_lb" {
  network_interface_id    = azurerm_network_interface.app_nic_2.id
  ip_configuration_name   = "app-nic-2-config"
  backend_address_pool_id = var.lb_backend_pool_id
}

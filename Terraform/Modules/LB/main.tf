#-------------Load Balancer Public IP (equivalent of ALB's auto DNS)-------------------#
resource "azurerm_public_ip" "lb_pip" {
  name                = "lb-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = "Load Balancer Public IP"
  }
}

#-------------Load Balancer (equivalent of aws_lb — internet-facing)-------------------#
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-frontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = {
    Name = var.lb_name
  }
}

#-------------Backend Address Pool (equivalent of aws_lb_target_group)-------------------#
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "app-backend-pool"
}

#-------------Health Probe (equivalent of ALB target group health_check block)-------------------#
# Mirrors original: path="/", interval=25s, timeout=8s, healthy=5, unhealthy=3
resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "http-health-probe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 25
  number_of_probes    = 3   # unhealthy threshold
}

#-------------Load Balancing Rule (equivalent of aws_lb_listener — HTTP:80 → backend:80)-------------------#
resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}

# Internal Load Balancer
resource "azurerm_lb" "internal_lb" {
  name                = "internal-loadbalancer"
  location            = var.location
  resource_group_name = var.res_grp_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                           = "internal-lb-fe"
    subnet_id                      = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "170.20.2.100" # use any available IP in the app subnet
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.internal_lb.id
  name            = "backend-pool"
}

# Health Probe
resource "azurerm_lb_probe" "health_probe" {
  loadbalancer_id     = azurerm_lb.internal_lb.id
  name                = "http-probe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancer Rule
resource "azurerm_lb_rule" "http_rule" {
  name                            = "http-rule"
  loadbalancer_id                 = azurerm_lb.internal_lb.id
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  frontend_ip_configuration_name  = "internal-lb-fe"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                        = azurerm_lb_probe.health_probe.id
}

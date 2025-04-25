locals {
  backend_address_pool_name      = "${azurerm_virtual_network.myvnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.myvnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.myvnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.myvnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.myvnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.myvnet.name}-rqrt"
}

resource "azurerm_application_gateway" "network" {
  name                = "bcpp3-appgateway"
  resource_group_name = azurerm_resource_group.res_grp.name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgateway_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pubip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  probe {
    name = "appgw-health-probe"
    protocol = "Http"
    path = "/"
    timeout = 30
    interval = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = false
    host = "172.20.2.100"
    minimum_servers = 0
    match {
      status_code = ["200","201"]
      body = "*"
    }
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name = "appgw-health-probe"
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 25
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
   depends_on = [ azurerm_resource_group.res_grp ]
}

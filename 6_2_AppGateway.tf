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
  resource_group_name = var.res_grp_name
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

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
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

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appgw-association" {
  network_interface_id    = azurerm_network_interface.web-nic.id
  ip_configuration_name   = "web-nic-ip"
  backend_address_pool_id = tolist(azurerm_application_gateway.network.backend_address_pool).0.id
   depends_on = [ azurerm_application_gateway.network ]
}
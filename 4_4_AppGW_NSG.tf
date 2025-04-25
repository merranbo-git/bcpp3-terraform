resource "azurerm_network_security_group" "appgwnsg" {
  name                = "appgw-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.res_grp.name

    security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges     = ["65200-65535"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowNodeJS"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [ azurerm_resource_group.res_grp ]

}
resource "azurerm_subnet_network_security_group_association" "appgwnsgconn" {
  subnet_id = azurerm_subnet.appgateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgwnsg.id
  depends_on = [ azurerm_network_security_group.appgwnsg ]
}
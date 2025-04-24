resource "azurerm_network_security_group" "webnsg" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.res_grp_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowNodeJS"
    priority                   = 104
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
resource "azurerm_subnet_network_security_group_association" "webnsgconn" {
  subnet_id = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.webnsg.id
   depends_on = [ azurerm_network_security_group.webnsg ]
}
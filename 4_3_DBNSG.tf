resource "azurerm_network_security_group" "dbnsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.res_grp.name

  security_rule {
    name                       = "AllowSQLRule"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = azurerm_subnet.app_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }
   depends_on = [ azurerm_resource_group.res_grp ]
}
resource "azurerm_subnet_network_security_group_association" "dbnsgconn" {
  subnet_id = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.dbnsg.id
  depends_on = [ azurerm_network_security_group.dbnsg ]
}
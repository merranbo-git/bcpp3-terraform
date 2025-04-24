resource "azurerm_network_interface" "web-nic" {
  name                = "web-nic"
  location            = var.location
  resource_group_name = var.res_grp_name
  ip_configuration {
    name                          = "web-nic-ip"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_resource_group.res_grp ]
}
resource "azurerm_network_interface" "app-nic" {
  name                = "app-nic"
  location            = var.location
  resource_group_name = var.res_grp_name
  ip_configuration {
    name                          = "app-nic-ip"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_resource_group.res_grp ]
}
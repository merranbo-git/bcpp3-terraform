resource "azurerm_public_ip" "pubip" {
  name                = "appgw-public-ip"
  location            = var.location
  resource_group_name = var.res_grp_name
  allocation_method   = "Static"
  sku                 = "Standard"
   depends_on = [ azurerm_resource_group.res_grp ]
}
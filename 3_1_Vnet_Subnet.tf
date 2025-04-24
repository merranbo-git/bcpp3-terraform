resource "azurerm_virtual_network" "myvnet" {
  name                = "bcpp3-vnet"
  address_space       = ["170.20.0.0/16"]
  location            = var.location
  resource_group_name = var.res_grp_name

  depends_on = [ azurerm_resource_group.res_grp ]
}
resource "azurerm_subnet" "appgateway_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = var.res_grp_name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["170.20.0.0/24"]
  depends_on = [ azurerm_resource_group.res_grp ]
}
resource "azurerm_subnet" "web_subnet" {
  name                 = "web-subnet"
  resource_group_name  = var.res_grp_name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["170.20.1.0/24"]
  depends_on = [ azurerm_resource_group.res_grp ]
}
resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  resource_group_name  = var.res_grp_name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["170.20.2.0/24"]
  depends_on = [ azurerm_resource_group.res_grp ]
}
resource "azurerm_subnet" "db_subnet" {
  name                 = "db-subnet"
  resource_group_name  = var.res_grp_name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["170.20.3.0/24"]

  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
depends_on = [ azurerm_resource_group.res_grp ]
}

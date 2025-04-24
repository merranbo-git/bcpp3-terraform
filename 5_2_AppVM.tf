resource "azurerm_linux_virtual_machine" "app-vm" {
  name                = "app-vm"
  resource_group_name = var.res_grp_name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.app-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/VM_Key/app-ssh-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  custom_data = base64encode(templatefile("${path.module}/Scripts/node_server.sh", {
  db_host = "${azurerm_mysql_flexible_server.sql_server.fqdn}",
  db_user = "${azurerm_mysql_flexible_server.sql_server.administrator_login}@${azurerm_mysql_flexible_server.sql_server.name}",
  db_pswd = "${azurerm_key_vault_secret.db_pass.value}"
}))
   depends_on = [ azurerm_resource_group.res_grp, azurerm_mysql_flexible_database.sql_db ]
}
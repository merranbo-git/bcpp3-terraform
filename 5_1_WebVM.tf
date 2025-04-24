resource "azurerm_linux_virtual_machine" "web-vm" {
  name                = "web-vm"
  resource_group_name = var.res_grp_name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.web-nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${path.module}/VM_Key/web-ssh-key.pub")
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
  
  #custom_data = filebase64("${path.module}/Scripts/web-vm-init.sh")
  custom_data = base64encode(templatefile("${path.module}/Scripts/web_init.sh", {
    app_ip = "${azurerm_linux_virtual_machine.app-vm.private_ip_address}"
  }))
  depends_on = [ azurerm_resource_group.res_grp, azurerm_linux_virtual_machine.app-vm ]
}
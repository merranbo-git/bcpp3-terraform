resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "app-vmss"
  resource_group_name = var.res_grp_name
  location            = var.location
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = var.admin_username
  upgrade_mode        = "Manual"

  zones = local.is_production ? ["1", "2"] : null

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/${var.app_ssh_key_path}")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "app-vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "app-nic-ip"
      subnet_id                              = azurerm_subnet.app_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pool.id]
    }
  }

  custom_data = base64encode(templatefile("${path.module}/Scripts/node_server.sh", {
    db_host = azurerm_mysql_flexible_server.sql_server.fqdn,
    db_user = "${azurerm_mysql_flexible_server.sql_server.administrator_login}@${azurerm_mysql_flexible_server.sql_server.name}",
    db_pswd = azurerm_key_vault_secret.db_pass.value
  }))
  
  tags = {
    environment = terraform.workspace
  }
  depends_on = [azurerm_resource_group.res_grp, azurerm_mysql_flexible_database.sql_db]
}

resource "azurerm_monitor_autoscale_setting" "app_vmss_autoscale" {
  name                = "app-vmss-autoscale"
  location            = var.location
  resource_group_name = var.res_grp_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app_vmss.id

  profile {
    name = "defaultProfile"
    capacity {
      minimum = "2"
      maximum = "5"
      default = "2"
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = {
    environment = terraform.workspace
  }

  depends_on = [azurerm_linux_virtual_machine_scale_set.app_vmss]
}

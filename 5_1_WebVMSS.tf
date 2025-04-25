locals {
  is_production = contains(["Prod", "Production", "prod", "production"], terraform.workspace)
}

resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "web-vmss"
  resource_group_name = var.res_grp_name
  location            = var.location
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = var.admin_username
  upgrade_mode        = "Manual"
  
  zones = local.is_production ? ["1", "2", "3"] : null

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/${var.web_ssh_key_path}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "web-vmss-nic"
    primary = true

    ip_configuration {
      name      = "web-nic-ip"
      subnet_id = azurerm_subnet.web_subnet.id
      application_gateway_backend_address_pool_ids = [for pool in azurerm_application_gateway.network.backend_address_pool : pool.id]
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pool.id]
      }
  }

  tags = {
    environment = terraform.workspace
  }
  
  custom_data = filebase64("${path.module}/Scripts/web_init.sh")

  depends_on = [
    azurerm_application_gateway.network,
    azurerm_resource_group.res_grp,
    azurerm_linux_virtual_machine_scale_set.app_vmss
  ]
}

resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "web-vmss-autoscale"
  location            = var.location
  resource_group_name = var.res_grp_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_vmss.id

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
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
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
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
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

  depends_on = [azurerm_linux_virtual_machine_scale_set.web_vmss]
}
resource "azurerm_key_vault" "kv" {
  name                        = "${var.res_grp_name}-kv"
  location                    = var.location
  resource_group_name         = var.res_grp_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

   key_permissions = [
      "Get", 
      "List",
      "Create",
      "Update",
      "Delete",
      "Purge"
    ]

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Backup",
      "Delete",
      "Restore",
      "Purge"
    ]
  }
  
  depends_on = [ azurerm_resource_group.res_grp ,data.azurerm_client_config.current]
}

resource "azurerm_key_vault_secret" "db_pass" {
  name         = "mysql-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_resource_group.res_grp, azurerm_key_vault.kv ]
}
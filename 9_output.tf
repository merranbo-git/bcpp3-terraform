output "public_ip_address" {
  value = azurerm_public_ip.pubip.ip_address
}
output "resurce_grp_name" {
  value = azurerm_resource_group.res_grp.name
}
output "sql-fqdn" {
  value = azurerm_mysql_flexible_server.sql_server.fqdn
}
output "sub_id" {
  value = data.azurerm_client_config.current.subscription_id
}
output "clientid" {
  value = data.azurerm_client_config.current.client_id
}
output "objectid" {
  value = data.azurerm_client_config.current.object_id
}
output "tenantid" {
  value = data.azurerm_client_config.current.tenant_id
}
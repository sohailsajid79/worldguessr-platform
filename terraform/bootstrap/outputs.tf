output "state_storage_account" {
  value = azurerm_storage_account.tfstate.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "github_client_id" {
  value = azuread_application.app_reg.client_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
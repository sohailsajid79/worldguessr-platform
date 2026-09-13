locals {
  gh_owner        = split("/", var.github_repo)[0]
  gh_repo         = split("/", var.github_repo)[1]
  gh_subject_main = "repo:${local.gh_owner}@${var.github_owner_id}/${local.gh_repo}@${var.github_repo_id}:ref:refs/heads/main"
}

data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}

resource "azuread_application" "app_reg" {
  display_name = "gh-${var.project}-platform"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app_reg.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_federated_identity_credential" "fic" {
  application_id = azuread_application.app_reg.id
  display_name   = "github-main"
  description    = "GitHub Actions, main branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = local.gh_subject_main
}

resource "azurerm_role_assignment" "github_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.sp.object_id
}
terraform {
  backend "azurerm" {
    subscription_id      = "647b7767-ba25-46c1-a06d-dd9597593c3e"
    resource_group_name  = "rg-worldguessr-bootstrap"
    storage_account_name = "stworldguessrtf37cgic"
    container_name       = "tfstate"
    key                  = "bootstrap.tfstate"
  }
}
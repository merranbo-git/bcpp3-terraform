terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
    backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = "3f48112c-a56d-44e0-9a80-1ed5fbce3aac"
  tenant_id = "2f21d037-c8a4-4b43-a799-121f2bb00fc2"
  client_id = "ff3a915d-fd53-4165-b52d-08f8cecca338"
  client_secret = "IEe8Q~OoB2SA5fdjcQuIieqFLWp6b~Ff9XO1gapW"

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "res_grp" {
  name     = var.res_grp_name
  location = var.location
}


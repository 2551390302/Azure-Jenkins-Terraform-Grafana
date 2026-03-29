terraform {
  backend "azurerm" {
    resource_group_name  = "rg-kk02-eas-devops01"
    storage_account_name = "sakk02easdevops01"
    container_name       = "tfstate"
    key                  = "devops1/dev.terraform.tfstate"
  }
}
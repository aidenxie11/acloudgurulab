terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  resource_provider_registrations = "none"
  features {}
  subscription_id = var.azure_subscription_id
  use_cli = true
}

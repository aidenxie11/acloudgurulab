terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }

  # backend "azurerm" {
  #   resource_group_name = "1-c3c9f8f0-playground-sandbox"
  #   storage_account_name = "terraformremotestatelab1"
  #   container_name = "tfstatefiles"
  #   key = "terraform.tfstate"
  # }
}

provider "azurerm" {
  # Configuration options
  resource_provider_registrations = "none"
  features {}
  subscription_id = var.azure_subscription_id
  use_cli         = true
}

resource "random_string" "myrandom" {
  length  = 6
  upper   = false
  special = false
  numeric = false
}


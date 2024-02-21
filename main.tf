# Configure the Azure provider
terraform {

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod-australiaeast"
    storage_account_name = "tfstateprode001"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias    = "connectivity"
  features {}
}

provider "azurerm" {
  alias    = "management"
  features {}
}


data "azurerm_client_config" "core" {}
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "5.1.0"
  
  default_location = "australiaeast"
  
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
  
  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = "charli-app"
  root_name      = "Non-Prod"
  deploy_connectivity_resources = true
  deploy_management_resources = true
}


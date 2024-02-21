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

data "azurerm_client_config" "core" {}
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "5.1.0" # not allowed - var.enterprise_scale_version_no  
  default_location = "australiaeast"
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = "charli-app"
  root_name      = "Non-Prod"
  subscription_id_connectivity  = data.azurerm_client_config.connectivity.subscription_id
  subscription_id_identity  = data.azurerm_client_config.identity.subscription_id
  subscription_id_management  = data.azurerm_client_config.management.subscription_id
  deploy_connectivity_resources = true
  deploy_management_resources = true
}

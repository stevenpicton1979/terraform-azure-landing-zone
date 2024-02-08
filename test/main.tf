# Configure the Azure provider
terraform {

  backend "azurerm" {
    resource_group_name   = "rg-tfstate-prod-australiaeast"
    storage_account_name  = "tfstateprode001"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup3"
  location = "australiaeast"
}

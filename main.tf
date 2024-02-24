# Configure the Azure provider
terraform {

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-devops-australiaeast"
    storage_account_name = "tfstatedevopse001"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
        azurerm.identity
      ]
    }
  }
}

# Declare a standard provider block using your preferred configuration.
# This will be used for the deployment of all "Core resources".

provider "azurerm" {
  features {}
}

# Declare an aliased provider block using your preferred configuration.
# This will be used for the deployment of all "Connectivity resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivity_subscription_id
  features {}
}

# Declare a standard provider block using your preferred configuration.
# This will be used for the deployment of all "Management resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id
  features {}
}

# Declare a standard provider block using your preferred configuration.
# This will be used for the deployment of all "Identity resources" to the specified `subscription_id`.

provider "azurerm" {
  alias           = "identity"
  subscription_id = var.identity_subscription_id
  features {}
}

# Obtain client configuration from the un-aliased provider
data "azurerm_client_config" "core" {
  provider = azurerm
}

# Obtain client configuration from the aliased 'management' provider
data "azurerm_client_config" "management" {
  provider = azurerm.management
}

# Obtain client configuration from the aliased 'connectivity' provider
data "azurerm_client_config" "connectivity" {
  provider = azurerm.connectivity
}

# Obtain client configuration from the aliased 'connectivity' provider
data "azurerm_client_config" "identity" {
  provider = azurerm.identity
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "5.1.0"
  
  default_location = "australiaeast"
  
  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }
  
   # Set the required input variable `root_parent_id` using the Tenant ID from the un-aliased provider
  root_id        = "platform"
  root_name      = "Platform"
  root_parent_id = data.azurerm_client_config.core.tenant_id

  # Enable deployment of the management resources, using the management
  # aliased provider to populate the correct Subscription ID
  deploy_management_resources = true
  subscription_id_management  = data.azurerm_client_config.management.subscription_id

  # Enable deployment of the connectivity resources, using the connectivity
  # aliased provider to populate the correct Subscription ID
  deploy_connectivity_resources = true
  subscription_id_connectivity  = data.azurerm_client_config.connectivity.subscription_id

  # Enable deployment of the identity resources
  subscription_id_identity  = data.azurerm_client_config.identity.subscription_id
}


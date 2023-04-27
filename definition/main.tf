terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "ASA-E-GitOps-State"
    storage_account_name = "asaegitopstfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

provider "azurerm" {
  features {}
  use_oidc = true
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_spring_cloud_service" "spring" {
  name                = var.service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "E0"
}

resource "azapi_resource" "buildservice" {
  type      = "Microsoft.AppPlatform/Spring/buildServices@2023-03-01-preview"
  name      = "default"
  parent_id = azurerm_spring_cloud_service.spring.id
  body = jsonencode({
    properties = {
    }
  })
}

resource "azapi_resource" "agentPool" {
  type      = "Microsoft.AppPlatform/Spring/buildServices/agentPools@2023-03-01-preview"
  name      = "default"
  parent_id = azapi_resource.buildservice.id
  body = jsonencode({
    properties = {
      poolSize = {
        name = "S1"
      }
    }
  })
}

resource "azapi_resource" "builder" {
  type      = "Microsoft.AppPlatform/Spring/buildServices/builders@2023-03-01-preview"
  name      = "default"
  parent_id = azapi_resource.buildservice.id
  body = jsonencode({
    properties = {
      buildpackGroups = [
        {
          buildpacks = [
            {
              id = "tanzu-buildpacks/java-azure"
            }
          ]
          name = "default"
        }
      ]
      stack = {
        id      = "io.buildpacks.stacks.bionic"
        version = "base"
      }
    }
  })
}

module "app-demo-time" {
  source = "../apps/demo-time/definition"

  resource_group_name = azurerm_spring_cloud_service.spring.resource_group_name
  service_name        = azurerm_spring_cloud_service.spring.name
}

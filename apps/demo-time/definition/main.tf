terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
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

data "azurerm_spring_cloud_service" "service" {
  name                = var.service_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_spring_cloud_app" "demo-time-app" {
  name                = "demo-time"
  resource_group_name = var.resource_group_name
  service_name        = var.service_name

  is_public = true
}

resource "azurerm_spring_cloud_build_deployment" "blue" {
  name                = "blue"
  spring_cloud_app_id = azurerm_spring_cloud_app.demo-time-app.id
  build_result_id     = "<default>"
  instance_count      = 2
  quota {
    cpu    = "2"
    memory = "4Gi"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      build_result_id,
    ]
  }
}

resource "azurerm_spring_cloud_build_deployment" "green" {
  name                = "green"
  spring_cloud_app_id = azurerm_spring_cloud_app.demo-time-app.id
  build_result_id     = "<default>"
  instance_count      = 2
  quota {
    cpu    = "2"
    memory = "4Gi"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      build_result_id,
    ]
  }
}

resource "azurerm_spring_cloud_gateway_route_config" "health_check" {
  name                    = "health-check"
  spring_cloud_gateway_id = format("%s/gateways/default", data.azurerm_spring_cloud_service.service.id)
  spring_cloud_app_id     = azurerm_spring_cloud_app.demo-time-app.id
  protocol                = "HTTP"
  route {
    description         = "Retrieve a health check from our application"
    filters             = ["StripPrefix=2", "RateLimit=1,1s"]
    order               = 1
    predicates          = ["Path=/actuator/health/", "Method=GET"]
    title               = "Test API"
    token_relay         = false
    classification_tags = ["health-check"]
  }
}

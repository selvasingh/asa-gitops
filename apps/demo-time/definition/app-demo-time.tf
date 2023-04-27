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
    memory = "2Gi"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes. Because the build_result_id will be changed by Deploy action.
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
    memory = "2Gi"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes. Because the build_result_id will be changed by Deploy action.
      build_result_id,
    ]
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "frontend_rg" {
  name     = "frontend_rg"
  location = "westeurope"
  tags = {
    projet = "academy2023"
    etudiant="MehdiBehira"
  }
}

resource "azurerm_service_plan" "frontend_plan" {
  name                = "frontend_plan"
  location            = azurerm_resource_group.frontend_rg.location
  resource_group_name = azurerm_resource_group.frontend_rg.name
  os_type             = "Linux"
  sku_name            = "B1"
    tags = {
    projet = "academy2023"
    etudiant="MehdiBehira"
  }

}


resource "azurerm_linux_web_app" "myfrontwebapp" {
  name                = "myfrontwebapp"
  location            = azurerm_resource_group.frontend_rg.location
  resource_group_name = azurerm_resource_group.frontend_rg.name
  service_plan_id  = azurerm_service_plan.frontend_plan.id
    tags = {
    projet = "academy2023"
    etudiant="MehdiBehira"
  }

  site_config {
    always_on           = true
  //linux_fx_version    = "DOCKER|ghcr.io/arcanexus/api-demo-frontend:latest"
  //  app_command_line         = "npm start"
        app_command_line         = "npm start"
        application_stack {
      docker_image     = "ghcr.io/arcanexus/api-demo-frontend"
      docker_image_tag = "latest"

    }
  }


  app_settings = {
    "WEBSITES_PORT" = "80"
  }

  identity {
    type = "SystemAssigned"
  }
}




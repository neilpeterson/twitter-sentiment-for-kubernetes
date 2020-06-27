provider "azurerm" {
  version = "=2.8.0"
  features {}
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

variable "identifier" {
  default = "twitter002"
}

variable "resourceGroupName" {
  default = "rg"
}

variable "location" {
  default = "eastus"
}

variable "aksName" {
  default = "aks"
}

variable "storageName" {
  default = "aks"
}

variable "cosmosName" {
  default = "cosmos"
}

variable "cogServicesName" {
  default = "cogs"
}

variable "script" {
  default = "https://raw.githubusercontent.com/neilpeterson/twitter-sentiment-for-kubernetes/arm-template/deployment/arm/deploymentScript.ps1"
}


resource "azurerm_resource_group" "resourceGroup" {
  name     = "${var.resourceGroupName}-${var.identifier}"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.aksName}-${var.identifier}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  dns_prefix          = "exampleaks1"
  kubernetes_version  = "1.16.9"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  role_based_access_control {
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "${var.storageName}${var.identifier}"
  resource_group_name      = azurerm_resource_group.resourceGroup.name
  location                 = azurerm_resource_group.resourceGroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Unique to Terraform, breaks shared deployment script
# resource "azurerm_storage_queue" "example" {
#   name                 = "${var.storageName}${var.identifier}"
#   storage_account_name = azurerm_storage_account.storage.name
# }

resource "azurerm_cosmosdb_account" "db" {
  name                = "${var.cosmosName}-${var.identifier}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = "Eventual"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}

resource "azurerm_cognitive_account" "example" {
  name                = "${var.cogServicesName}-${var.identifier}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  kind                = "TextAnalytics"
  sku_name            = "S0"
}

# Managed Identity (Deployment Script)
resource "azurerm_user_assigned_identity" "script-identity" {
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  name                = "deployment-script-identity"
}

resource "azurerm_role_assignment" "script-identity-assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.script-identity.principal_id
}

resource "azurerm_template_deployment" "domaindata" {
  name                = "domaindata"
  resource_group_name = azurerm_resource_group.resourceGroup.name

  template_body = <<DEPLOY
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "scriptIdentity": {
           "type": "securestring"
        },
        "aksName": {
           "type": "string"
        },
        "storageAccountName": {
            "type": "string"
        },
        "script": {
            "type": "securestring"
        }
    },
    "resources": [
        {
            "type": "Microsoft.Resources/deploymentScripts",
            "apiVersion": "2019-10-01-preview",
            "name": "runPowerShellInline",
            "location": "[resourceGroup().location]",
            "kind": "AzurePowerShell",
            "identity": {
                "type": "UserAssigned",
                "userAssignedIdentities": {"[parameters('scriptIdentity')]": {}}
            },
            "properties": {
                "forceUpdateTag": "1",
                "azPowerShellVersion": "3.0",
                "arguments": "[concat('-aksCluster ', parameters('aksName'), ' -aksResourceGroup ', resourceGroup().name, ' -storageAccountName ', parameters('storageAccountName'))]",
                "primaryScriptUri": "[parameters('script')]",
                "timeout": "PT30M",
                "cleanupPreference": "OnSuccess",
                "retentionInterval": "P1D"
            }
        }
    ]
}
DEPLOY

  parameters = {
    "scriptIdentity"        = azurerm_user_assigned_identity.script-identity.id,
    "aksName"               = azurerm_kubernetes_cluster.aks.name,
    "storageAccountName"    = azurerm_storage_account.storage.name,
    "script"                = var.script
  }

  deployment_mode = "Incremental"
}
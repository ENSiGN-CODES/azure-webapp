terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateformonty"   # must be globally unique — change if taken
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    # State locking is built-in with Azure Blob Storage (lease-based) — no separate DynamoDB needed
  }
}

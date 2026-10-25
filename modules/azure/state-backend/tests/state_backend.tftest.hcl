# Native Terraform Test for Azure State Backend Module
# Uses mock_provider to test storage account and container security configurations.

mock_provider "azurerm" {}

run "verify_storage_security_settings" {
  command = plan

  variables {
    resource_group_name  = "rg-tfstate-eastus-dev"
    location             = "eastus"
    storage_account_name = "sttfstatedev12345678"
    container_name       = "tfstate"
  }

  assert {
    condition     = azurerm_storage_account.state.account_tier == "Standard"
    error_message = "Storage tier must be Standard."
  }

  assert {
    condition     = azurerm_storage_account.state.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS version must be TLS1_2."
  }

  assert {
    condition     = azurerm_storage_account.state.shared_access_key_enabled == false
    error_message = "Shared access keys must be disabled to enforce Entra ID auth."
  }

  assert {
    condition     = azurerm_storage_account.state.allow_nested_items_to_be_public == false
    error_message = "Public access to nested items must be disabled."
  }

  assert {
    condition     = azurerm_storage_container.state.container_access_type == "private"
    error_message = "Container access type must be private."
  }
}

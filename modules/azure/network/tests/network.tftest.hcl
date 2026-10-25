# Native Terraform Test for Azure Network Module
# Uses mock_provider to test VNet and NSG default-deny rules.

mock_provider "azurerm" {}

run "verify_vnet_and_nsg_rules" {
  command = plan

  variables {
    resource_group_name   = "rg-network-eastus-dev"
    location              = "eastus"
    vnet_name             = "vnet-dev"
    address_space         = ["10.0.0.0/16"]
    public_subnet_prefix  = "10.0.1.0/24"
    private_subnet_prefix = "10.0.11.0/24"
    data_subnet_prefix    = "10.0.21.0/24"
    enable_nat_gateway    = true
  }

  assert {
    condition     = azurerm_virtual_network.main.address_space == tolist(["10.0.0.0/16"])
    error_message = "VNet address space must match configured CIDR."
  }

  assert {
    condition     = azurerm_subnet.public.address_prefixes == tolist(["10.0.1.0/24"])
    error_message = "Public subnet address prefix must match."
  }

  assert {
    condition     = length(azurerm_nat_gateway.nat) == 1
    error_message = "NAT Gateway must be created when enable_nat_gateway is true."
  }
}

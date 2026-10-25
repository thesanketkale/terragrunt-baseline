output "resource_group_name" {
  value       = azurerm_resource_group.net.name
  description = "Name of the networking resource group."
}

output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "The ID of the Azure Virtual Network."
}

output "vnet_name" {
  value       = azurerm_virtual_network.main.name
  description = "The name of the Azure Virtual Network."
}

output "public_subnet_id" {
  value       = azurerm_subnet.public.id
  description = "The ID of the public frontend subnet."
}

output "private_subnet_id" {
  value       = azurerm_subnet.private.id
  description = "The ID of the private application subnet."
}

output "data_subnet_id" {
  value       = azurerm_subnet.data.id
  description = "The ID of the isolated database subnet."
}

output "nat_gateway_id" {
  value       = var.enable_nat_gateway ? azurerm_nat_gateway.nat[0].id : null
  description = "The ID of the NAT Gateway if enabled."
}

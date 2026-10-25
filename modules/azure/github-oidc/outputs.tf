output "client_id" {
  value       = azuread_application.github.client_id
  description = "The Client ID (App ID) of the Entra ID application."
}

output "service_principal_id" {
  value       = azuread_service_principal.github.id
  description = "The Object ID of the service principal."
}

output "application_id" {
  value       = azuread_application.github.id
  description = "The Object ID of the Entra ID application."
}

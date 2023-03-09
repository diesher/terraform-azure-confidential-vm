
#-----------------------------------
# key vault - Output
#-----------------------------------
#-----------------------------------
# Key vault - Outputs
#-----------------------------------

output "key_vault_id" {
  description = "key vault id"
  value       = azurerm_key_vault.key_vault.id
}

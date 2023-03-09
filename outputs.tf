
#-----------------------------------
# key vault - Outputs
#-----------------------------------

output "key_vault_id" {
  description = "key vault id"
  value       = module.keyvault.key_vault_id
}

#-----------------------------------
# disk encryption set - Output
#-----------------------------------

output "disk_encryption_set_id" {
  description = "disk encryption set id"
  value       = module.disk_encryption_set.0.disk_encryption_set_id
}

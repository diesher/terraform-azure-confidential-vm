#-----------------------------------
# disk encryption set - Output
#-----------------------------------

output "disk_encryption_set_id" {
  description = "disk encryption set id"
  value       = azurerm_disk_encryption_set.disk_encryption_set.id
}


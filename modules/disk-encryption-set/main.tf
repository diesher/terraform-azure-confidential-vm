data "azurerm_client_config" "current" {}

#-----------------------------------
# Create an encryption key
#-----------------------------------
resource "azurerm_key_vault_key" "kv_key" {
  name         = var.disk_encryption_set_key_name
  key_vault_id = var.key_vault_id
  key_type     = "RSA-HSM"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

}

#-----------------------------------
# Create a disk encryption set
#-----------------------------------
resource "azurerm_disk_encryption_set" "disk_encryption_set" {
  name                = var.disk_encryption_set_name
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.kv_key.id
  encryption_type     = "ConfidentialVmEncryptedWithCustomerKey"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "kv_access_policy_disk" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_disk_encryption_set.disk_encryption_set.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.disk_encryption_set.identity.0.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "UnwrapKey",
    "WrapKey",
  ]
}

#-----------------------------------
# Grant permissions to the disk encryption set
#-----------------------------------
resource "azurerm_role_assignment" "kv_role_assignment_disk" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.disk_encryption_set.identity.0.principal_id
}
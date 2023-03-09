#-----------------------------------
# Create a random string of characters
#-----------------------------------
resource "random_string" "random" {
  length  = 5
  lower   = true
  special = false
}

#-----------------------------------
# Create key vault
#-----------------------------------
resource "azurerm_key_vault" "key_vault" {

  name                        = "${var.key_vault_name}-${random_string.random.result}"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
}

#-----------------------------------
# Create Access policy for the current user
#-----------------------------------
resource "azurerm_key_vault_access_policy" "kv_access_policy_user" {
  key_vault_id = azurerm_key_vault.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "ManageContacts",
    "ManageIssuers",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers",
    "Purge",
  ]

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Update",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
    "WrapKey",
    "UnwrapKey",
    "Verify",
    "Encrypt",
    "Decrypt",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
  ]

}
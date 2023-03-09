variable "resource_group_name" {
  type = string
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "disk_encryption_set_name" {
  type        = string
  description = "The name of the disk encryption set to use for enabling encryption at rest"
}

variable "disk_encryption_set_key_name" {
  type        = string
  description = "The name of the key to be used for encryption"
  default     = "diskEncryptionKey"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault to which this Disk Encryption Set should be associated."
}

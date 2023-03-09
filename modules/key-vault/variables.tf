variable "resource_group_name" {
  type = string
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default = "westeurope"
}

variable "key_vault_name" {
  type = string
  description = "The name of the Key Vault to be created"
}

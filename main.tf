module "naming" {
  source  = "Azure/naming/azurerm"
  suffix = [ var.app_name, var.environment ]
}

#-----------------------------------
# create Resource group
#-----------------------------------
resource "azurerm_resource_group" "resource_group" {
  count    = var.resource_group_name == null ? 1 : 0
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location

  tags = var.tags
}

#-----------------------------------
# Create the network VNET
#-----------------------------------
resource "azurerm_virtual_network" "network-vnet" {
  count = var.vnet_name == null ? 1 : 0

  name                = "vnet-${lower(replace(var.app_name, " ", "-"))}-${var.environment}"
  resource_group_name = coalesce(var.resource_group_name, azurerm_resource_group.resource_group.0.name)
  location            = var.location
  address_space       = var.network-vnet-cidr
  tags                = var.tags
}

#-----------------------------------
# Create a key vault
#-----------------------------------
module "keyvault" {
  source              = "./modules/key-vault"
  resource_group_name = coalesce(var.resource_group_name, azurerm_resource_group.resource_group.0.name)

  key_vault_name = module.naming.key_vault.name
  location    = var.location
}

#-----------------------------------
# Create a disk encryption set
#-----------------------------------
module "disk_encryption_set" {

  source = "./modules/disk-encryption-set"

  depends_on = [
    module.keyvault
  ]

  count = var.enable_disk_encryption_set ? 1 : 0

  resource_group_name = coalesce(var.resource_group_name, azurerm_resource_group.resource_group.0.name)
  disk_encryption_set_name = module.naming.disk_encryption_set.name
  disk_encryption_set_key_name = "key-${module.naming.disk_encryption_set.name}"
  location            = var.location
  key_vault_id        = module.keyvault.key_vault_id

}

#-----------------------------------
# Create a vm
#-----------------------------------
module "vm" {
  source = "./modules/vm"

  depends_on = [
    module.keyvault,
    module.disk_encryption_set
  ]

  # Resource Group, location, key vault details
  resource_group_name = coalesce(var.resource_group_name, azurerm_resource_group.resource_group.0.name)

  location            = var.location
  key_vault_id        = module.keyvault.key_vault_id

  # Network details
  vnet_name           = coalesce(var.vnet_name, azurerm_virtual_network.network-vnet.0.name)
  subnet_name         = var.subnet_name
  network-subnet-cidr = var.network-subnet-cidr
  nsg_inbound_rules   = var.nsg_inbound_rules

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  enable_proximity_placement_group = var.enable_proximity_placement_group
  enable_vm_availability_set       = var.enable_vm_availability_set
  enable_public_ip_address         = var.enable_public_ip_address

  # VM details
  os_flavor                       = var.os_flavor
  virtual_machine_name            = module.naming.virtual_machine.name
  instances_count                 = var.instances_count
  admin_username                  = var.admin_username
  disable_password_authentication = var.os_flavor == "linux" ? var.disable_password_authentication : false
  generate_admin_ssh_key          = var.os_flavor == "linux" ? var.generate_admin_ssh_key : false
  distribution_name               = var.distribution_name
  virtual_machine_size            = var.virtual_machine_size
  os_disk_storage_account_type    = var.os_disk_storage_account_type
  disk_encryption_set_id          = coalesce(module.disk_encryption_set.0.disk_encryption_set_id, null)

  tags = var.tags

}
#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VM's (Dev Environment only)
#---------------------------------------------------------------
resource "tls_private_key" "ssh" {
  count     = var.generate_admin_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  count = var.generate_admin_ssh_key ? 1 : 0

  name         = "ssh-private-key-${var.virtual_machine_name}"
  value        = tls_private_key.ssh.0.private_key_pem
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [
      value, key_vault_id
    ]
  }
}

resource "azurerm_key_vault_secret" "ssh_public_key_openssh" {
  count = var.generate_admin_ssh_key ? 1 : 0

  name         = "ssh-public-key-${var.virtual_machine_name}"
  value        = tls_private_key.ssh.0.public_key_openssh
  key_vault_id = var.key_vault_id

  lifecycle {
    ignore_changes = [
      value, key_vault_id
    ]
  }
}

#----------------------------------------------------------
# Create Random Resources
#----------------------------------------------------------

resource "random_password" "passwd" {
  count       = (var.os_flavor == "linux" && var.disable_password_authentication == false && var.admin_password == null ? 1 : (var.os_flavor == "windows" && var.admin_password == null ? 1 : 0))
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    admin_password = var.virtual_machine_name
  }
}

#-----------------------------------
# Create the subnet VNET
#-----------------------------------
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.network-subnet-cidr]
  virtual_network_name = var.vnet_name

}

#-----------------------------------
# Public IP for Virtual Machine
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip_address == true ? var.instances_count : 0
  name                = lower("pip-${lower(replace(var.virtual_machine_name, " ", "-"))}-0${count.index + 1}")
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  sku_tier            = var.public_ip_sku_tier
  domain_name_label   = var.domain_name_label
  zones               = var.public_ip_availability_zones
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags,
      ip_tags,
    ]
  }
}

#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                   = var.instances_count
  name                    = var.instances_count == 1 ? lower("nic-${format("vm%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")))}") : lower("nic-${format("vm%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
  resource_group_name     = var.resource_group_name
  location                = var.location
  dns_servers             = var.dns_servers
  enable_ip_forwarding    = var.enable_ip_forwarding
  internal_dns_name_label = var.internal_dns_name_label

  ip_configuration {
    name                          = lower("ipconig-${format("vm%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = var.private_ip_address_allocation_type
    private_ip_address            = var.private_ip_address_allocation_type == "Static" ? element(concat(var.private_ip_address, [""]), count.index) : null
    public_ip_address_id          = var.enable_public_ip_address == true ? element(concat(azurerm_public_ip.pip.*.id, [""]), count.index) : null
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#----------------------------------------------------------------------------------------------------
# Proximity placement group for virtual machines, virtual machine scale sets and availability sets.
#----------------------------------------------------------------------------------------------------
resource "azurerm_proximity_placement_group" "appgrp" {
  count               = var.enable_proximity_placement_group ? 1 : 0
  name                = lower("proxigrp-${var.virtual_machine_name}-${var.location}")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#-----------------------------------------------------
# Manages an Availability Set for Virtual Machines.
#-----------------------------------------------------
resource "azurerm_availability_set" "aset" {
  count                        = var.enable_vm_availability_set ? 1 : 0
  name                         = "avset-${var.virtual_machine_name}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  managed                      = true
  tags                         = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#---------------------------------------------------------------
# Network security group for Virtual Machine Network Interface
#---------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  count               = var.existing_network_security_group_id == null ? 1 : 0
  name                = lower("nsg_${var.virtual_machine_name}_${var.location}_in")
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_network_security_rule" "nsg_rule" {
  for_each                    = { for k, v in local.nsg_inbound_rules : k => v if k != null }
  name                        = each.key
  priority                    = 100 * (each.value.idx + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.security_rule.destination_port_range
  source_address_prefix       = each.value.security_rule.source_address_prefix
  destination_address_prefix  = element(concat(azurerm_subnet.subnet.address_prefixes, [""]), 0)
  description                 = "Inbound_Port_${each.value.security_rule.destination_port_range}"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.0.name
  depends_on                  = [azurerm_network_security_group.nsg]
}

resource "azurerm_network_interface_security_group_association" "nsgassoc" {
  count                     = var.instances_count
  network_interface_id      = element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)
  network_security_group_id = var.existing_network_security_group_id == null ? azurerm_network_security_group.nsg.0.id : var.existing_network_security_group_id
}

#---------------------------------------
# Linux Virutal machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "linux_vm" {
  count                           = var.os_flavor == "linux" ? var.instances_count : 0
  name                            = var.instances_count == 1 ? substr(var.virtual_machine_name, 0, 64) : substr(format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 64)
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.virtual_machine_size
  admin_username                  = var.admin_username
  admin_password                  = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_ids           = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  source_image_id                 = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent              = true
  allow_extension_operations      = true
  vtpm_enabled                    = true
  secure_boot_enabled             = true
  custom_data                     = var.custom_data != null ? var.custom_data : null
  availability_set_id             = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  proximity_placement_group_id    = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  zone                            = var.vm_availability_zone
  tags                            = var.tags

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.admin_ssh_key_data == null ? tls_private_key.ssh[0].public_key_openssh : file(var.admin_ssh_key_data)
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? var.custom_image["publisher"] : local.distribution_list[lower(var.distribution_name)]["publisher"]
      offer     = var.custom_image != null ? var.custom_image["offer"] : local.distribution_list[lower(var.distribution_name)]["offer"]
      sku       = var.custom_image != null ? var.custom_image["sku"] : local.distribution_list[lower(var.distribution_name)]["sku"]
      version   = var.custom_image != null ? var.custom_image["version"] : local.distribution_list[lower(var.distribution_name)]["version"]
    }
  }

  os_disk {
    storage_account_type             = var.os_disk_storage_account_type
    caching                          = var.os_disk_caching
    secure_vm_disk_encryption_set_id = var.disk_encryption_set_id
    security_encryption_type         = "DiskWithVMGuestState"
    disk_size_gb                     = var.disk_size_gb
    write_accelerator_enabled        = var.enable_os_disk_write_accelerator
    name                             = var.os_disk_name
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#---------------------------------------
# Windows Virutal machine
#---------------------------------------
resource "azurerm_windows_virtual_machine" "win_vm" {
  count                        = var.os_flavor == "windows" ? var.instances_count : 0
  name                         = var.instances_count == 1 ? substr(var.virtual_machine_name, 0, 15) : substr(format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15)
  computer_name                = var.instances_count == 1 ? substr(var.virtual_machine_name, 0, 15) : substr(format("%s%s", lower(replace(var.virtual_machine_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15)
  resource_group_name          = var.resource_group_name
  location                     = var.location
  size                         = var.virtual_machine_size
  admin_username               = var.admin_username
  admin_password               = var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  network_interface_ids        = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  source_image_id              = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent           = true
  allow_extension_operations   = true
  vtpm_enabled                 = true
  secure_boot_enabled          = true
  custom_data                  = var.custom_data != null ? var.custom_data : null
  enable_automatic_updates     = var.enable_automatic_updates
  license_type                 = var.license_type
  availability_set_id          = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  patch_mode                   = var.patch_mode
  zone                         = var.vm_availability_zone
  timezone                     = var.vm_time_zone
  tags                         = var.tags

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? var.custom_image["publisher"] : local.distribution_list[lower(var.distribution_name)]["publisher"]
      offer     = var.custom_image != null ? var.custom_image["offer"] : local.distribution_list[lower(var.distribution_name)]["offer"]
      sku       = var.custom_image != null ? var.custom_image["sku"] : local.distribution_list[lower(var.distribution_name)]["sku"]
      version   = var.custom_image != null ? var.custom_image["version"] : local.distribution_list[lower(var.distribution_name)]["version"]
    }
  }

  os_disk {
    storage_account_type             = var.os_disk_storage_account_type
    caching                          = var.os_disk_caching
    secure_vm_disk_encryption_set_id = var.disk_encryption_set_id
    security_encryption_type         = "DiskWithVMGuestState"
    disk_size_gb                     = var.disk_size_gb
    write_accelerator_enabled        = var.enable_os_disk_write_accelerator
    name                             = var.os_disk_name
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      patch_mode,
    ]
  }
}

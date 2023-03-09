
locals {
  nsg_inbound_rules = { for idx, security_rule in var.nsg_inbound_rules : security_rule.name => {
    idx : idx,
    security_rule : security_rule,
    }
  }


  linux_image_references = {
    ubuntu_2004_cvm = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-confidential-vm-focal"
      sku       = "20_04-lts-cvm"
      version   = "latest"
    },
    ubuntu_2204_cvm = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-confidential-vm-focal"
      sku       = "22_04-lts-cvm"
      version   = "latest"
    },
  }

  windows_image_references = {
    windows_dc_2019_cvm = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-smalldisk-g2"
      version   = "latest"
    },

    windows_dc_2022_cvm = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-smalldisk-g2"
      version   = "latest"
    },
  }

  linux_distribution_list   = lower(var.os_flavor) == "linux" ? local.linux_image_references : null
  windows_distribution_list = lower(var.os_flavor) == "windows" ? local.windows_image_references : null
  distribution_list         = coalesce(local.linux_distribution_list, local.windows_distribution_list)

}


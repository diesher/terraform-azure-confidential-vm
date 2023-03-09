
variable "resource_group_name" {
  type = string
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "westeurope"
}

variable "vnet_name" {
  type = string
  description = "The name of the VNET"
  default     = null
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet"
  default     = "subnet"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault to which this Disk Encryption Set should be associated."
}

variable "network-subnet-cidr" { 
  type        = string
  description = "The CIDR for the network subnet"
}

variable "random_password_length" {
  type        = number
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "enable_public_ip_address" {
  type        = bool
  description = "Reference to a Public IP Address to associate with the NIC"
  default     = null
}

variable "public_ip_allocation_method" {
  type = string
  description = "Defines the allocation method for this IP address. Possible values are `Static` or `Dynamic`"
  default     = "Static"
}

variable "public_ip_sku" {
  type = string
  description = "The SKU of the Public IP. Accepted values are `Basic` and `Standard`"
  default     = "Standard"
}

variable "domain_name_label" {
  type        = string
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = null
}

variable "public_ip_availability_zones" {
  type        = list(string)
  description = "The availability zone to allocate the Public IP in. Possible values are `Zone-Redundant`, `1`,`2`, `3`, and `No-Zone`"
  default     = []
}

variable "public_ip_sku_tier" {
  type        = string
  description = "The SKU Tier that should be used for the Public IP. Possible values are `Regional` and `Global`"
  default     = "Regional"
}

variable "dns_servers" {
  type        = list(string)
  description = "List of dns servers to use for network interface"
  default     = []
}

variable "enable_ip_forwarding" {
  type        = bool
  description = "Should IP Forwarding be enabled? Defaults to false"
  default     = false
}

variable "internal_dns_name_label" {
  type        = string
  description = "The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network."
  default     = null
}

variable "private_ip_address_allocation_type" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  default     = "Dynamic"
}

variable "private_ip_address" {
  type        = string
  description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` "
  default     = null
}

variable "enable_vm_availability_set" {
  type = bool
  description = "Manages an Availability Set for Virtual Machines."
  default     = false
}

variable "availability_set_name" {  
  type = string
  description = "The name of the availability set."
  default     = null
}

variable "platform_fault_domain_count" {
  type = number
  description = "Specifies the number of fault domains that are used"
  default     = 3
}
variable "platform_update_domain_count" {
  type = number
  description = "Specifies the number of update domains that are used"
  default     = 5
}

variable "enable_proximity_placement_group" {
  type = bool
  description = "Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets."
  default     = false
}

variable "existing_network_security_group_id" {
  type        = string
  description = "The resource id of existing network security group"
  default     = null
}

variable "nsg_inbound_rules" {
  type = list(any)
  description = "List of network rules to apply to network interface."
  default     = []
}

variable "virtual_machine_name" {
  type = string
  description = "The name of the virtual machine."
  default     = ""
}

variable "instances_count" {
  type = number
  description = "The number of Virtual Machines required."
  default     = 1
}

variable "os_flavor" {
  type =  string
  description = "Specify the flavor of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux`"
  default     = "windows"
}

variable "virtual_machine_size" {
  type = string
  description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
  default     = "Standard_DC2ads_v5"
}

variable "disable_password_authentication" {
  type = bool
  description = "Should Password Authentication be disabled on this Virtual Machine? Defaults to true."
  default     = true
}

variable "admin_username" {
  type = string
  description = "The username of the local administrator used for the Virtual Machine."
  default     = "azureadmin"
}

variable "admin_password" {
  type = string
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  default     = null
}

variable "source_image_id" {
  type = string
  description = "The ID of an Image which each Virtual Machine should be based on"
  default     = null
}

variable "custom_data" {
  type = string
  description = "Base64 encoded file of a bash script that gets run once by cloud-init upon VM creation"
  default     = null
}

variable "enable_automatic_updates" {
  type = bool
  description = "Specifies if Automatic Updates are Enabled for the Windows Virtual Machine."
  default     = true
}


variable "vm_availability_zone" {
  type = string
  description = "The Zone in which this Virtual Machine should be created. Conflicts with availability set and shouldn't use both"
  default     = null
}

variable "patch_mode" {
  type = string
  description = "Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are `Manual`, `AutomaticByOS` and `AutomaticByPlatform`"
  default     = "AutomaticByOS"
}

variable "license_type" {
  type = string
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  default     = "None"
}

variable "vm_time_zone" {
  type = string
  description = "Specifies the Time Zone which should be used by the Virtual Machine"
  default     = null
}

variable "generate_admin_ssh_key" {
  type = bool
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
}

variable "admin_ssh_key_data" {
  type = string
  description = "specify the path to the existing SSH key to authenticate Linux virtual machine"
  default     = null
}

variable "custom_image" {
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
  description = "Provide the custom image to this module if the default variants are not sufficient"
  default = null
}

variable "distribution_name" {
  type        = string
  description = "Variable to pick an OS flavour for Linux based VM. Possible values include: centos8, ubuntu1804"
  validation {
    condition     = contains(["ubuntu_2004_cvm", "ubuntu_2204_cvm", "windows_dc_2019_cvm", "windows_dc_2022_cvm"], var.distribution_name)
    error_message = "The distribution name is not valid. Please choose one of the following: ubuntu_2004_cvm, ubuntu_2204_cvm, windows_dc_2019_cvm, windows_dc_2022_cvm."

  }
}

variable "os_disk_storage_account_type" {
  type = string
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
  default     = "StandardSSD_LRS"
}

variable "os_disk_caching" {
  type = string
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`"
  default     = "ReadWrite"
}

variable "disk_encryption_set_id" {
  type = string
  description = "The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault"
  default     = null
}

variable "disk_size_gb" {
  type = number
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from."
  default     = null
}

variable "enable_os_disk_write_accelerator" {
  type = bool
  description = "Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`."
  default     = false
}

variable "os_disk_name" {
  type = string
  description = "The name which should be used for the Internal OS Disk"
  default     = null
}

variable "managed_identity_type" {
  type = string
  description = "The type of Managed Identity which should be assigned to the Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = null
}

variable "managed_identity_ids" {
  type = list(string)
  description = "A list of User Managed Identity ID's which should be assigned to the Linux Virtual Machine."
  default     = null
}

variable "key_vault_certificate_secret_url" {
  type = string
  description = "The Secret URL of a Key Vault Certificate, which must be specified when `protocol` is set to `Https`"
  default     = null
}


variable "tags" { 
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}



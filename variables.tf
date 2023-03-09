variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the resources are created."
  default     = null
}
variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = ""
}

variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "environment" {
  type        = string
  description = "Name of the envrionment"
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNET"
  default     = null
}


variable "network-vnet-cidr" {
  description = "The CIDR of the network VNET"
  type        = list(string)
}

variable "network-subnet-cidr" {
  description = "The CIDR for the network subnet"
  type        = string
}


variable "subnet_name" {
  type        = string
  description = "The name of the subnet to use in VM scale set"
  default     = ""
}

variable "enable_disk_encryption_set" {
  type        = bool
  description = "Enable disk encryption set"
  default     = false
}

variable "disk_encryption_set_id" {
  type        = string
  description = "The ID of the disk encryption set to use for enabling encryption at rest"
  default     = null
}

variable "random_password_length" {
  type        = number
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "enable_public_ip_address" {
  type        = bool
  description = "Reference to a Public IP Address to associate with the NIC"
  default     = false
}


variable "public_ip_sku" {
  type        = string
  description = "The SKU of the Public IP. Accepted values are `Basic` and `Standard`"
  default     = "Standard"
}

variable "domain_name_label" {
  type        = string
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = null
}

variable "public_ip_availability_zone" {
  type        = string
  description = "The availability zone to allocate the Public IP in. Possible values are `Zone-Redundant`, `1`,`2`, `3`, and `No-Zone`"
  default     = "Zone-Redundant"
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
  type        = bool
  description = "Manages an Availability Set for Virtual Machines."
  default     = false
}

variable "platform_fault_domain_count" {
  type        = number
  description = "Specifies the number of fault domains that are used"
  default     = 3
}
variable "platform_update_domain_count" {
  type        = number
  description = "Specifies the number of update domains that are used"
  default     = 5
}

variable "enable_proximity_placement_group" {
  type        = bool
  description = "Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets."
  default     = false
}

variable "existing_network_security_group_id" {
  type        = string
  description = "The resource id of existing network security group"
  default     = null
}

variable "nsg_inbound_rules" {
  type        = list(any)
  description = "List of network rules to apply to network interface."
  default     = []
}

variable "virtual_machine_name" {
  type        = string
  description = "The name of the virtual machine."
}

variable "instances_count" {
  type        = number
  description = "The number of Virtual Machines required."
  default     = 1
}

variable "os_flavor" {
  type        = string
  description = "Specify the flavor of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux`"
  default     = "windows"
}

variable "virtual_machine_size" {
  type        = string
  description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
  default     = "Standard_DC2ads_v5"
}

variable "disable_password_authentication" {
  type        = bool
  description = "Should Password Authentication be disabled on this Virtual Machine? Defaults to true."
  default     = true
}

variable "admin_username" {
  type        = string
  description = "The username of the local administrator used for the Virtual Machine."
  default     = "azureadmin"
}

variable "admin_password" {
  type        = string
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  default     = null
}

variable "generate_admin_ssh_key" {
  type        = bool
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
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
  type        = string
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
  default     = "StandardSSD_LRS"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = {}
}


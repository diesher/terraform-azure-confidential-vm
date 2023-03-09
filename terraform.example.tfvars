app_name    = "confidential" # Name of the app
environment = "dev"          # Environment name
location    = "westeurope"   # Location of the resources

network-vnet-cidr   = ["10.0.1.0/26"]
network-subnet-cidr = "10.0.1.0/27" # CIDR of the network
subnet_name         = "snet-applications"

enable_disk_encryption_set = true

virtual_machine_name            = "vm-win-cvm"
disable_password_authentication = true
admin_username                  = "azureuser"
os_flavor                       = "windows"
distribution_name               = "windows_dc_2019_cvm"
virtual_machine_size            = "Standard_DC2ads_v5"
generate_admin_ssh_key          = true
os_disk_storage_account_type    = "Premium_LRS"
instances_count                 = 2

# Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
enable_proximity_placement_group = true
enable_vm_availability_set       = true
enable_public_ip_address         = true

nsg_inbound_rules = [
  {
    name                   = "ssh"
    destination_port_range = "22"
    source_address_prefix  = "*"
  },
  {
    name                   = "http"
    destination_port_range = "80"
    source_address_prefix  = "*"
  },
]






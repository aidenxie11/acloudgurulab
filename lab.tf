# 创建网络安全组（NSG）并添加入站规则
# resource "azurerm_network_security_group" "myrg" {
#   name                = "mynsg"
#   location            = azurerm_resource_group.myrg.location
#   resource_group_name = azurerm_resource_group.myrg.name

#   security_rule {
#     name                       = "allow-ssh"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     name                       = "allow-http"
#     priority                   = 200
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# # 将网络安全组关联到子网
# resource "azurerm_subnet_network_security_group_association" "myrg" {
#   subnet_id                 = azurerm_subnet.mysubnet.id
#   network_security_group_id = azurerm_network_security_group.myrg.id
# }

# Create Virtual Network
resource "azurerm_virtual_network" "myvnet" {
  name                = "${var.virtual_network_name}-${var.business_unit}-${var.environment}"
  address_space       = var.virtual_network_address_space
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  tags                = var.common_tags
}

# # Create Subnet
# resource "azurerm_subnet" "mysubnet" {
#   name                 = "${var.subnet_name}-${azurerm_virtual_network.myvnet.name}"
#   resource_group_name  = azurerm_resource_group.myrg.name
#   virtual_network_name = azurerm_virtual_network.myvnet.name
#   address_prefixes     = ["10.3.2.0/24"]
# }

# # Create Azure Public IP Address
# resource "azurerm_public_ip" "mypublicip" {
#   for_each            = toset(["vm1", "vm2"])
#   name                = "mypublicip-${each.key}"
#   resource_group_name = azurerm_resource_group.myrg.name
#   location            = azurerm_resource_group.myrg.location
#   allocation_method   = "Static"
#   domain_name_label   = "app1-${each.key}-${random_string.myrandom.id}"
#   sku                 = lookup(var.public_ip_sku, var.location, "Basic")
#   tags                = var.common_tags
# }

# # Create Network Interface
# resource "azurerm_network_interface" "myvmnic" {
#   for_each            = toset(["vm1", "vm2"])
#   name                = "vmnic-${each.key}"
#   location            = azurerm_resource_group.myrg.location
#   resource_group_name = azurerm_resource_group.myrg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.mysubnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.mypublicip[each.key].id
#   }
#   tags = var.common_tags
# }

# # Resource: Azure Linux Virtual Machine
# resource "azurerm_linux_virtual_machine" "mylinuxvm" {
#   #for_each = toset(["vm1", "vm2"])  
#   for_each = azurerm_network_interface.myvmnic #for_each chaining
#   name                = "mylinuxvm-${each.key}"
#   computer_name       = "devlinux-${each.key}" # Hostname of the VM
#   resource_group_name = azurerm_resource_group.myrg.name
#   location            = azurerm_resource_group.myrg.location
#   size                = "Standard_DS1_v2"
#   admin_username      = "azureuser"
#   network_interface_ids = [azurerm_network_interface.myvmnic[each.key].id]
#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = file("${path.module}/ssh-keys/id_rsa.pub")
#   }
#   os_disk {
#     name = "osdisk${each.key}"
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#     #disk_size_gb = 20
#   }
#   source_image_reference {
#     publisher = "RedHat"
#     offer     = "RHEL"
#     sku       = "83-gen2"
#     version   = "latest"
#   }
#   custom_data = filebase64("${path.module}/app-scripts/app1-cloud-init.txt")
# }

# resource "azurerm_virtual_network" "main" {
#   name                = "mylabvnet-1"
# #   name                = "mylabvnet-2"
#   address_space       = ["10.200.0.0/16"]
#   location            = azurerm_resource_group.myrg.location
#   resource_group_name = azurerm_resource_group.myrg.name
#   tags = {
#     "Environment" = "Production"
#     "name" = "mylabvnet-1"
#   }
#   lifecycle {
#     ignore_changes = [ 
#         tags,
#      ]
#   }
# }

# resource "azurerm_mssql_server" "mysqlserver" {
#   name                         = "${var.business_unit}-${var.environment}-${var.db_name}"
#   resource_group_name          = azurerm_resource_group.myrg.name
#   location                     = azurerm_resource_group.myrg.location
#   version                      = "12.0"
#   administrator_login          = var.db_username
#   administrator_login_password = var.db_password
#   tags = var.common_tags
# }

# resource "azurerm_mssql_database" "webappdb1" {
#   name         = "webappdb1"
#   server_id    = azurerm_mssql_server.mysqlserver.id
#   collation    = "SQL_Latin1_General_CP1_CI_AS"
#   license_type = "LicenseIncluded"
#   max_size_gb  = 2
#   sku_name     = "S0"
#   enclave_type = "VBS"

#   tags = var.common_tags

#   # prevent the possibility of accidental data loss
#   lifecycle {
#     prevent_destroy = true
#   }
# }
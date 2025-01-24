# 创建虚拟网络
resource "azurerm_virtual_network" "myrg" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

# 创建虚拟机子网
resource "azurerm_subnet" "vm" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myrg.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 创建Bastion子网（必须使用特定名称）
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"  # 必须使用这个名称
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myrg.name
  address_prefixes     = ["10.0.2.0/24"]       # 最小需要 /27
}

# 创建公共IP（用于Bastion）
resource "azurerm_public_ip" "bastion" {
  name                = "bastion-pip"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 创建Bastion主机
resource "azurerm_bastion_host" "myrg" {
  name                = "mybastion"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# 创建网络安全组
resource "azurerm_network_security_group" "myrg" {
  name                = "win10-nsg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 创建网络接口
resource "azurerm_network_interface" "myrg" {
  name                = "win10-nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 关联NSG到网络接口
resource "azurerm_network_interface_security_group_association" "myrg" {
  network_interface_id      = azurerm_network_interface.myrg.id
  network_security_group_id = azurerm_network_security_group.myrg.id
}

# 创建Windows 10虚拟机
resource "azurerm_windows_virtual_machine" "myrg" {
  name                = "win10-vm"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"  # 请修改为强密码
  network_interface_ids = [
    azurerm_network_interface.myrg.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-pro-g2"  # Windows 10版本
    version   = "latest"
  }
}

# 输出Bastion主机信息
output "bastion_host_name" {
  value = azurerm_bastion_host.myrg.name
}
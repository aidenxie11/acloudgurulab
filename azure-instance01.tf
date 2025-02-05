variable "prefix" {
  default = "test-aiden"
}

resource "azurerm_resource_group" "myrg" {
  name     = var.resource_group_name
  location = var.location
}

# 创建虚拟网络
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

# 创建子网
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 创建公共 IP 地址（Standard SKU + Static）
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-publicip"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Static" # 必须为 Static
  sku                 = "Standard" # Standard SKU
}

# 创建应用程序安全组（ASG）
resource "azurerm_application_security_group" "myrg" {
  name                = "${var.prefix}-asg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

# 创建网络安全组（NSG）并添加入站规则
resource "azurerm_network_security_group" "myrg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 将网络安全组关联到子网
resource "azurerm_subnet_network_security_group_association" "myrg" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.myrg.id
}

# 创建网络接口，并关联公共 IP 地址和应用程序安全组
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id # 关联公共 IP 地址
  }
}

# 将网络接口关联到应用程序安全组
resource "azurerm_network_interface_application_security_group_association" "myrg" {
  network_interface_id          = azurerm_network_interface.main.id
  application_security_group_id = azurerm_application_security_group.myrg.id
}

# 创建虚拟机
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.myrg.location
  resource_group_name   = azurerm_resource_group.myrg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "test"
  }

}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                 = "${var.prefix}-custom-script"
  virtual_machine_id   = azurerm_virtual_machine.main.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "script": "${base64encode(<<-EOF
        #!/bin/bash
        # 设置环境变量
        export HOME=/home/testadmin
        export USER=testadmin

        # 添加 HashiCorp 的 APT 仓库
        sudo apt-get update
        sudo apt-get install -y software-properties-common
        wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list


        # 安装 Docker
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io

        # 启动并启用 Docker 服务
        sudo systemctl start docker
        sudo systemctl enable docker

        # 安装 code-server
        curl -fsSL https://code-server.dev/install.sh | sh

        # 安装 authbind
        sudo apt-get install -y authbind

        # 配置 authbind
        sudo touch /etc/authbind/byport/80
        sudo chmod 500 /etc/authbind/byport/80
        sudo chown $USER /etc/authbind/byport/80

        # 创建 code-server 配置文件
        mkdir -p ~/.config/code-server
        cat > ~/.config/code-server/config.yaml <<EOL
        bind-addr: 0.0.0.0:80
        auth: password
        password: your_password
        cert: false
        EOL

        # # 使用 authbind 启动 code-server
        # authbind --deep code-server
        # 配置 code-server 为 systemd 服务
        sudo cat > /etc/systemd/system/code-server.service <<EOL
        [Unit]
        Description=code-server
        After=network.target

        [Service]
        ExecStart=/usr/bin/authbind --deep /usr/bin/code-server
        Restart=always
        User=testadmin
        Environment=HOME=/home/testadmin

        [Install]
        WantedBy=multi-user.target
        EOL

        # 启动并启用 code-server 服务
        sudo systemctl daemon-reload
        sudo systemctl start code-server
        sudo systemctl enable code-server

        # 安装 Terraform
        sudo apt-get install -y terraform

        sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
        curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

        AZ_REPO=$(lsb_release -cs)
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
        sudo apt-get update
        sudo apt-get install azure-cli
      EOF
      )}"
    }
  SETTINGS
}
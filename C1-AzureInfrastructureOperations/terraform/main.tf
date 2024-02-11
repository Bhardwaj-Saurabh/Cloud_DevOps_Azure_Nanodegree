provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
  lifecycle {
    ignore_changes = [
      location,  # Ignore changes to the location attribute
    ]
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
 name                 = "${var.prefix}-subnet"
 resource_group_name  = azurerm_resource_group.main.name
 virtual_network_name = azurerm_virtual_network.main.name
 address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "main" {
 count               = var.num_of_vms
 name                = "${var.prefix}-${count.index}-nic"
 location            = azurerm_resource_group.main.location
 resource_group_name = azurerm_resource_group.main.name
 ip_configuration {
   name                          = "internal"
   subnet_id                     = azurerm_subnet.main.id
   private_ip_address_allocation = "Dynamic"
 }
 tags = var.tags
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_lb" "main" {
 name                = "${var.prefix}-lb"
 location            = azurerm_resource_group.main.location
 resource_group_name = azurerm_resource_group.main.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.main.id
 }

 tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
 loadbalancer_id     = azurerm_lb.main.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                     = var.num_of_vms
  network_interface_id      = azurerm_network_interface.main[count.index].id
  ip_configuration_name     = "internal"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.main.id
}


resource "azurerm_availability_set" "main" {
 name                         = "${var.prefix}-aset"
 location                     = azurerm_resource_group.main.location
 resource_group_name          = azurerm_resource_group.main.name
 managed                      = true
tags = var.tags
}

data "azurerm_image" "image" {
  name                = var.packer_image_name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_virtual_machine" "main" {
  count                           = var.num_of_vms
  name                            = "${var.prefix}${count.index}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  vm_size                         = "Standard_B1s"
  network_interface_ids = [element(azurerm_network_interface.main.*.id, count.index)]
  availability_set_id = azurerm_availability_set.main.id

  storage_image_reference  {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
   computer_name  =  "hostname${count.index}"
   admin_username                  = "aryan"
   admin_password                  = "password@123"
  }

  os_profile_linux_config {
   disable_password_authentication = false
  }

  storage_os_disk  {
   name              = "WSdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location 
  resource_group_name = azurerm_resource_group.main.name 
  tags = var.tags
}

# Lowest Priority Rule - Deny Inbound Traffic from the Internet
resource "azurerm_network_security_rule" "rule1" {
  name                        = "DenyAllInbound"
  description                 = "This rule with low priority deny all the inbound traffic."
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_network_security_group.main.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Inbound Rule - Allow traffic within the Same Virtual Network
resource "azurerm_network_security_rule" "rule2" {
  name                        = "AllowInboundVnet"
  description                 = "This rule allow the inbound traffic inside the same virtual network."
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_network_security_group.main.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Outbound Rule - Allow traffic within the Same Virtual Network
resource "azurerm_network_security_rule" "rule3" {
  name                        = "AllowOutboundInsideVN"
  description                 = "This rule allow the outbound traffic inside the same virtual network."
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_network_security_group.main.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Inbound Rule - Allow HTTP Traffic from the Load Balancer to the VMs
resource "azurerm_network_security_rule" "rule4" {
  name                        = "AllowHTTPFromLB"
  description                 = "This rule allow the HTTP traffic from the load balancer."
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_network_security_group.main.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

## Introduction

This project includes the creation and deployment of a highly customizable and scalable IaaS web server on Microsoft Azure using HashiCorp Packer and Terraform. It is designed to allow users to quickly and efficiently deploy a web server environment by specifying their own configurations, such as the Azure subscription ID, client ID, and client secret. The scalability feature of the project enables users to define the required number of virtual machines (VMs) based on their needs, ensuring that the deployment can handle varying loads.

## Getting Started
To utilize this project for deploying your own scalable web server in Azure, follow these steps:

**Clone this Repository:** Start by cloning this repository to your local machine to get access to all necessary files for deployment.

**Create Your Infrastructure as Code:** Utilize the provided Packer and Terraform templates to define your infrastructure.

**Customize the Deployment:** Modify the provided templates with your specific Azure credentials and desired configurations.

## Dependencies
**Azure Account:** You'll need an active Azure account. If you don't have one, sign up for a free trial.
**Azure CLI:** Install the Azure Command Line Interface to interact with Azure resources.
**Packer:** Install Packer for creating the server images.
**Terraform:** Install Terraform for deploying the infrastructure.

## Instructions
### 1. Create Azure Credentials
Generate a service principal in Azure with the following command:
```
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```
Update the client_id, client_secret, and tenant_id in the webserver.json Packer template with the output from the above command.

### 2. Customizing and Scaling the Web Server

The num_of_vms variable in the variable.tf file is set to 2 by default. Adjust this number according to your requirements.

Customize other configurations such as packer_image_name, packer_resource_group, tags, resource_group, and location in the variable.tf file.

### 3. Enforcing Resource Tagging Policy

- Create the Azure policy definition to deny creation of untagged resources by running create_az_policy_definition.sh.
- Assign the policy using the Azure Portal.
- Verify policy assignment with az policy assignment list.

### 4. Create a Server Image with Packer
Create an image resource group using:
```
az group create --location northeurope --name PolicyRG
```
Fill in the required fields in the server.json Packer template.

Build the Packer image with packer build webserver.json.

Use az image list and az image delete to manage your images.

### 5. Deploy Infrastructure with Terraform

- Prepare main.tf and variable.tf with your desired infrastructure configuration.

- Initialize Terraform with terraform init.

- Review the deployment plan using terraform plan -out solution.plan.

- Apply the deployment with terraform apply "solution.plan".

### 6. Cleanup

Destroy all resources created by Terraform with terraform destroy.
Delete the Packer image with `az image delete -g PolicyRG -n <packer image name>`

## Output
After successfully applying the Terraform configuration, you should have a fully functional, scalable web server deployed in Azure. Below are screenshots demonstrating the outcomes:

Packer Image Creation: 

<img src="policy/tagging-policy-screenshot.png"> 

Terraform Apply Result: 

```
(env) (base) saurabhbhardwaj@MacBook-Pro terraform % terraform plan -out solution.plan
azurerm_resource_group.main: Refreshing state... [id=/subscriptions/373225e3-4428-4fd7-bd11-c0f187aa1371/resourceGroups/Azuredevops]
data.azurerm_image.image: Reading...

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform planned the following actions, but then encountered a problem:

  # azurerm_availability_set.main will be created
  + resource "azurerm_availability_set" "main" {
      + id                           = (known after apply)
      + location                     = "eastus"
      + managed                      = true
      + name                         = "project-aset"
      + platform_fault_domain_count  = 3
      + platform_update_domain_count = 5
      + resource_group_name          = "Azuredevops"
      + tags                         = {
          + "Name" = "project"
        }
    }

  # azurerm_lb.main will be created
  + resource "azurerm_lb" "main" {
      + id                   = (known after apply)
      + location             = "eastus"
      + name                 = "project-lb"
      + private_ip_address   = (known after apply)
      + private_ip_addresses = (known after apply)
      + resource_group_name  = "Azuredevops"
      + sku                  = "Basic"
      + sku_tier             = "Regional"
      + tags                 = {
          + "Name" = "project"
        }

      + frontend_ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + id                                                 = (known after apply)
          + inbound_nat_rules                                  = (known after apply)
          + load_balancer_rules                                = (known after apply)
          + name                                               = "publicIPAddress"
          + outbound_rules                                     = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = (known after apply)
          + private_ip_address_version                         = (known after apply)
          + public_ip_address_id                               = (known after apply)
          + public_ip_prefix_id                                = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_lb_backend_address_pool.main will be created
  + resource "azurerm_lb_backend_address_pool" "main" {
      + backend_ip_configurations = (known after apply)
      + id                        = (known after apply)
      + inbound_nat_rules         = (known after apply)
      + load_balancing_rules      = (known after apply)
      + loadbalancer_id           = (known after apply)
      + name                      = "BackEndAddressPool"
      + outbound_rules            = (known after apply)
    }

  # azurerm_network_interface.main[0] will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "eastus"
      + mac_address                   = (known after apply)
      + name                          = "project-0-nic"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "Azuredevops"
      + tags                          = {
          + "Name" = "project"
        }
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_interface.main[1] will be created
  + resource "azurerm_network_interface" "main" {
      + applied_dns_servers           = (known after apply)
      + dns_servers                   = (known after apply)
      + enable_accelerated_networking = false
      + enable_ip_forwarding          = false
      + id                            = (known after apply)
      + internal_dns_name_label       = (known after apply)
      + internal_domain_name_suffix   = (known after apply)
      + location                      = "eastus"
      + mac_address                   = (known after apply)
      + name                          = "project-1-nic"
      + private_ip_address            = (known after apply)
      + private_ip_addresses          = (known after apply)
      + resource_group_name           = "Azuredevops"
      + tags                          = {
          + "Name" = "project"
        }
      + virtual_machine_id            = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_interface_backend_address_pool_association.main[0] will be created
  + resource "azurerm_network_interface_backend_address_pool_association" "main" {
      + backend_address_pool_id = (known after apply)
      + id                      = (known after apply)
      + ip_configuration_name   = "internal"
      + network_interface_id    = (known after apply)
    }

  # azurerm_network_interface_backend_address_pool_association.main[1] will be created
  + resource "azurerm_network_interface_backend_address_pool_association" "main" {
      + backend_address_pool_id = (known after apply)
      + id                      = (known after apply)
      + ip_configuration_name   = "internal"
      + network_interface_id    = (known after apply)
    }

  # azurerm_network_security_group.main will be created
  + resource "azurerm_network_security_group" "main" {
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "project-nsg"
      + resource_group_name = "Azuredevops"
      + security_rule       = (known after apply)
      + tags                = {
          + "Name" = "project"
        }
    }

  # azurerm_network_security_rule.rule1 will be created
  + resource "azurerm_network_security_rule" "rule1" {
      + access                      = "Deny"
      + description                 = "This rule with low priority deny all the inbound traffic."
      + destination_address_prefix  = "*"
      + destination_port_range      = "*"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "DenyAllInbound"
      + network_security_group_name = "project-nsg"
      + priority                    = 100
      + protocol                    = "*"
      + resource_group_name         = "Azuredevops"
      + source_address_prefix       = "*"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.rule2 will be created
  + resource "azurerm_network_security_rule" "rule2" {
      + access                      = "Allow"
      + description                 = "This rule allow the inbound traffic inside the same virtual network."
      + destination_address_prefix  = "VirtualNetwork"
      + destination_port_range      = "*"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "AllowInboundVnet"
      + network_security_group_name = "project-nsg"
      + priority                    = 101
      + protocol                    = "*"
      + resource_group_name         = "Azuredevops"
      + source_address_prefix       = "VirtualNetwork"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.rule3 will be created
  + resource "azurerm_network_security_rule" "rule3" {
      + access                      = "Allow"
      + description                 = "This rule allow the outbound traffic inside the same virtual network."
      + destination_address_prefix  = "VirtualNetwork"
      + destination_port_range      = "*"
      + direction                   = "Outbound"
      + id                          = (known after apply)
      + name                        = "AllowOutboundInsideVN"
      + network_security_group_name = "project-nsg"
      + priority                    = 101
      + protocol                    = "*"
      + resource_group_name         = "Azuredevops"
      + source_address_prefix       = "VirtualNetwork"
      + source_port_range           = "*"
    }

  # azurerm_network_security_rule.rule4 will be created
  + resource "azurerm_network_security_rule" "rule4" {
      + access                      = "Allow"
      + description                 = "This rule allow the HTTP traffic from the load balancer."
      + destination_address_prefix  = "VirtualNetwork"
      + destination_port_range      = "80"
      + direction                   = "Inbound"
      + id                          = (known after apply)
      + name                        = "AllowHTTPFromLB"
      + network_security_group_name = "project-nsg"
      + priority                    = 103
      + protocol                    = "Tcp"
      + resource_group_name         = "Azuredevops"
      + source_address_prefix       = "AzureLoadBalancer"
      + source_port_range           = "*"
    }

  # azurerm_public_ip.main will be created
  + resource "azurerm_public_ip" "main" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "project-public-ip"
      + resource_group_name     = "Azuredevops"
      + sku                     = "Basic"
      + sku_tier                = "Regional"
      + tags                    = {
          + "Name" = "project"
        }
    }

  # azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes                               = [
          + "10.0.0.0/24",
        ]
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "project-subnet"
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "Azuredevops"
      + virtual_network_name                           = "project-network"
    }

  # azurerm_virtual_machine.main[0] will be created
  + resource "azurerm_virtual_machine" "main" {
      + availability_set_id              = (known after apply)
      + delete_data_disks_on_termination = false
      + delete_os_disk_on_termination    = false
      + id                               = (known after apply)
      + license_type                     = (known after apply)
      + location                         = "eastus"
      + name                             = "project0-vm"
      + network_interface_ids            = (known after apply)
      + resource_group_name              = "Azuredevops"
      + vm_size                          = "Standard_B1s"

      + os_profile {
          # At least one attribute in this block is (or was) sensitive,
          # so its contents will not be displayed.
        }

      + os_profile_linux_config {
          + disable_password_authentication = false
        }

      + storage_image_reference {
          + offer     = "UbuntuServer"
          + publisher = "Canonical"
          + sku       = "18.04-LTS"
          + version   = "latest"
        }

      + storage_os_disk {
          + caching                   = "ReadWrite"
          + create_option             = "FromImage"
          + disk_size_gb              = (known after apply)
          + managed_disk_id           = (known after apply)
          + managed_disk_type         = "Standard_LRS"
          + name                      = "WSdisk0"
          + os_type                   = (known after apply)
          + write_accelerator_enabled = false
        }
    }

  # azurerm_virtual_machine.main[1] will be created
  + resource "azurerm_virtual_machine" "main" {
      + availability_set_id              = (known after apply)
      + delete_data_disks_on_termination = false
      + delete_os_disk_on_termination    = false
      + id                               = (known after apply)
      + license_type                     = (known after apply)
      + location                         = "eastus"
      + name                             = "project1-vm"
      + network_interface_ids            = (known after apply)
      + resource_group_name              = "Azuredevops"
      + vm_size                          = "Standard_B1s"

      + os_profile {
          # At least one attribute in this block is (or was) sensitive,
          # so its contents will not be displayed.
        }

      + os_profile_linux_config {
          + disable_password_authentication = false
        }

      + storage_image_reference {
          + offer     = "UbuntuServer"
          + publisher = "Canonical"
          + sku       = "18.04-LTS"
          + version   = "latest"
        }

      + storage_os_disk {
          + caching                   = "ReadWrite"
          + create_option             = "FromImage"
          + disk_size_gb              = (known after apply)
          + managed_disk_id           = (known after apply)
          + managed_disk_type         = "Standard_LRS"
          + name                      = "WSdisk1"
          + os_type                   = (known after apply)
          + write_accelerator_enabled = false
        }
    }

  # azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = [
          + "10.0.0.0/24",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "project-network"
      + resource_group_name = "Azuredevops"
      + subnet              = (known after apply)
      + tags                = {
          + "Name" = "project"
        }
    }

Plan: 17 to add, 0 to change, 0 to destroy.
```
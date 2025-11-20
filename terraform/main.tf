terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Configure backend in terraform/backend.tfvars.example
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstate<unique>"
    # container_name       = "tfstate"
    # key                  = "honeynet.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "honeynet" {
  name     = var.resource_group_name
  location = var.location
  
  tags = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "honeynet" {
  name                = "${var.project_name}-law"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  tags = var.tags
}

# Microsoft Sentinel
resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  name                       = "AzureActiveDirectory"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.honeynet.id
}

resource "azurerm_sentinel_data_connector_azure_security_center" "asc" {
  name                       = "AzureSecurityCenter"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.honeynet.id
}

# Virtual Network
resource "azurerm_virtual_network" "honeynet" {
  name                = "${var.project_name}-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  
  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "honeynet" {
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.honeynet.name
  virtual_network_name = azurerm_virtual_network.honeynet.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Network Security Group (Initially permissive for honeynet)
resource "azurerm_network_security_group" "honeynet" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  
  # Allow all inbound for honeynet (can be hardened later)
  security_rule {
    name                       = "AllowAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = var.hardened ? "Deny" : "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix       = "*"
    destination_address_prefix = "*"
    description                = "Honeynet: Allow all inbound traffic (before hardening)"
  }
  
  # Allow admin workstation (if hardened)
  dynamic "security_rule" {
    for_each = var.hardened && var.admin_ip != "" ? [1] : []
    content {
      name                       = "AllowAdminWorkstation"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = var.admin_ip
      destination_address_prefix = "*"
      description                = "Allow access from admin workstation"
    }
  }
  
  tags = var.tags
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "honeynet" {
  subnet_id                 = azurerm_subnet.honeynet.id
  network_security_group_id = azurerm_network_security_group.honeynet.id
}

# Public IPs for VMs
resource "azurerm_public_ip" "windows_vm_1" {
  name                = "${var.project_name}-win-vm1-pip"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

resource "azurerm_public_ip" "windows_vm_2" {
  name                = "${var.project_name}-win-vm2-pip"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

resource "azurerm_public_ip" "linux_vm" {
  name                = "${var.project_name}-linux-vm-pip"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

# Network Interfaces
resource "azurerm_network_interface" "windows_vm_1" {
  name                = "${var.project_name}-win-vm1-nic"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.honeynet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_vm_1.id
  }
  
  tags = var.tags
}

resource "azurerm_network_interface" "windows_vm_2" {
  name                = "${var.project_name}-win-vm2-nic"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.honeynet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows_vm_2.id
  }
  
  tags = var.tags
}

resource "azurerm_network_interface" "linux_vm" {
  name                = "${var.project_name}-linux-vm-nic"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.honeynet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux_vm.id
  }
  
  tags = var.tags
}

# Azure Key Vault
resource "azurerm_key_vault" "honeynet" {
  name                = "${var.project_name}-kv-${substr(md5(azurerm_resource_group.honeynet.id), 0, 8)}"
  location            = azurerm_resource_group.honeynet.location
  resource_group_name = azurerm_resource_group.honeynet.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  # Enable diagnostic settings for logging
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enabled_for_disk_encryption     = false
  
  network_acls {
    default_action = var.hardened ? "Deny" : "Allow"
    bypass         = "AzureServices"
  }
  
  tags = var.tags
}

# Key Vault Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "${var.project_name}-kv-diagnostics"
  target_resource_id         = azurerm_key_vault.honeynet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.honeynet.id
  
  log {
    category = "AuditEvent"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = 30
    }
  }
  
  metric {
    category = "AllMetrics"
    enabled  = true
    
    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# Storage Account
resource "azurerm_storage_account" "honeynet" {
  name                     = "${var.project_name}sa${substr(md5(azurerm_resource_group.honeynet.id), 0, 8)}"
  resource_group_name      = azurerm_resource_group.honeynet.name
  location                 = azurerm_resource_group.honeynet.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  
  # Enable blob logging
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  
  tags = var.tags
}

# Storage Account Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  name                       = "${var.project_name}-sa-diagnostics"
  target_resource_id         = azurerm_storage_account.honeynet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.honeynet.id
  
  log {
    category = "StorageRead"
    enabled  = true
  }
  
  log {
    category = "StorageWrite"
    enabled  = true
  }
  
  log {
    category = "StorageDelete"
    enabled  = true
  }
  
  metric {
    category = "Transaction"
    enabled  = true
  }
}

# Windows VMs
resource "azurerm_windows_virtual_machine" "windows_vm_1" {
  name                = "${var.project_name}-win-vm1"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  size                = var.vm_size
  admin_username      = var.windows_admin_username
  admin_password      = var.windows_admin_password
  
  network_interface_ids = [
    azurerm_network_interface.windows_vm_1.id,
  ]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  
  # Enable Log Analytics extension
  extension {
    name                 = "OMSExtension"
    publisher            = "Microsoft.EnterpriseCloud.Monitoring"
    type                 = "MicrosoftMonitoringAgent"
    type_handler_version = "1.0"
    
    settings = jsonencode({
      workspaceId = azurerm_log_analytics_workspace.honeynet.workspace_id
    })
    
    protected_settings = jsonencode({
      workspaceKey = azurerm_log_analytics_workspace.honeynet.primary_shared_key
    })
  }
  
  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "windows_vm_2" {
  name                = "${var.project_name}-win-vm2"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  size                = var.vm_size
  admin_username      = var.windows_admin_username
  admin_password      = var.windows_admin_password
  
  network_interface_ids = [
    azurerm_network_interface.windows_vm_2.id,
  ]
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  
  # Enable Log Analytics extension
  extension {
    name                 = "OMSExtension"
    publisher            = "Microsoft.EnterpriseCloud.Monitoring"
    type                 = "MicrosoftMonitoringAgent"
    type_handler_version = "1.0"
    
    settings = jsonencode({
      workspaceId = azurerm_log_analytics_workspace.honeynet.workspace_id
    })
    
    protected_settings = jsonencode({
      workspaceKey = azurerm_log_analytics_workspace.honeynet.primary_shared_key
    })
  }
  
  tags = var.tags
}

# Linux VM
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "${var.project_name}-linux-vm"
  resource_group_name = azurerm_resource_group.honeynet.name
  location            = azurerm_resource_group.honeynet.location
  size                = var.vm_size
  admin_username      = var.linux_admin_username
  
  network_interface_ids = [
    azurerm_network_interface.linux_vm.id,
  ]
  
  admin_ssh_key {
    username   = var.linux_admin_username
    public_key = var.linux_ssh_public_key
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  # Enable Log Analytics extension
  extension {
    name                 = "OMSExtension"
    publisher            = "Microsoft.EnterpriseCloud.Monitoring"
    type                 = "OmsAgentForLinux"
    type_handler_version = "1.0"
    
    settings = jsonencode({
      workspaceId = azurerm_log_analytics_workspace.honeynet.workspace_id
    })
    
    protected_settings = jsonencode({
      workspaceKey = azurerm_log_analytics_workspace.honeynet.primary_shared_key
    })
  }
  
  tags = var.tags
}

# Data source for current Azure client config
data "azurerm_client_config" "current" {}


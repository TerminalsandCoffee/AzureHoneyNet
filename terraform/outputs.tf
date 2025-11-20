output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.honeynet.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.honeynet.workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.honeynet.name
}

output "sentinel_workspace_id" {
  description = "Microsoft Sentinel workspace ID"
  value       = azurerm_log_analytics_workspace.honeynet.id
}

output "windows_vm_1_public_ip" {
  description = "Public IP address of Windows VM 1"
  value       = azurerm_public_ip.windows_vm_1.ip_address
}

output "windows_vm_2_public_ip" {
  description = "Public IP address of Windows VM 2"
  value       = azurerm_public_ip.windows_vm_2.ip_address
}

output "linux_vm_public_ip" {
  description = "Public IP address of Linux VM"
  value       = azurerm_public_ip.linux_vm.ip_address
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.honeynet.name
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.honeynet.name
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.honeynet.name
}

output "nsg_name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.honeynet.name
}


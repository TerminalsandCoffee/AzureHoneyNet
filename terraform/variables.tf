variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-honeynet"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "honeynet"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B2s" # 2 vCPUs, 4GB RAM - cost-effective for honeynet
}

variable "hardened" {
  description = "Whether to deploy in hardened mode (restrictive NSG rules)"
  type        = bool
  default     = false
}

variable "admin_ip" {
  description = "Admin workstation IP address for hardened mode"
  type        = string
  default     = ""
}

variable "windows_admin_username" {
  description = "Admin username for Windows VMs"
  type        = string
  default     = "azureadmin"
  sensitive   = true
}

variable "windows_admin_password" {
  description = "Admin password for Windows VMs"
  type        = string
  sensitive   = true
}

variable "linux_admin_username" {
  description = "Admin username for Linux VM"
  type        = string
  default     = "azureadmin"
}

variable "linux_ssh_public_key" {
  description = "SSH public key for Linux VM"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Honeynet"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}


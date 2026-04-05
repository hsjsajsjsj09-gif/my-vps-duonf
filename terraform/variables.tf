variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "mcvps"
}

variable "resource_group_name" {
  description = "Base resource group name (random suffix will be appended)"
  type        = string
  default     = "rg-minecraft-gpu"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "GPU VM size"
  type        = string
  default     = "Standard_NV6ads_A10_v5"
}

variable "admin_username" {
  description = "Windows admin username"
  type        = string
}

variable "admin_password" {
  description = "Windows admin password"
  type        = string
  sensitive   = true
}

variable "allowed_rdp_cidr" {
  description = "CIDR allowed to access RDP (e.g. x.x.x.x/32)"
  type        = string
}

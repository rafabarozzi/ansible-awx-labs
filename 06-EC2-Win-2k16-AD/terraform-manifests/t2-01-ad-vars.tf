variable "domain_name" {
  type        = string
  default = "rbarozzi.local"
}

variable "dc_name" {
  type        = string
  default = "ntdc01"  
}


variable "domain_netbios_name" {
  type        = string
  default = "rbarozzi"
}

variable "domain_mode" {
  type        = string
  default     = "WinThreshold" # Windows Server 2016 mode
}

variable "vm_admin_username" {
  type        = string
  default = "adminuser"
}

variable "domain_admin_password" {
  type        = string
  default = "Raf$Password!123"
}

variable "database_path" {
  type        = string
  default     = "C:/Windows/NTDS"
}

variable "sysvol_path" {
  type        = string
  default     = "C:/Windows/SYSVOL"
}

variable "log_path" {
  type        = string
  default     = "C:/Windows/NTDS"
}

variable "safe_mode_administrator_password" {
  type        = string
  default = "Raf$Password!123"  
}

locals { 
  cmd01 = "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools"
  cmd02 = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  cmd03 = "Import-Module ADDSDeployment, DnsServer"
  cmd04 = "Install-ADDSForest -DomainName ${var.domain_name} -DomainNetbiosName ${var.domain_netbios_name} -DomainMode ${var.domain_mode} -ForestMode ${var.domain_mode} -DatabasePath ${var.database_path} -SysvolPath ${var.sysvol_path} -LogPath ${var.log_path} -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString ${var.safe_mode_administrator_password} -AsPlainText -Force)"
  powershell = "${local.cmd01}; ${local.cmd02}; ${local.cmd03}; ${local.cmd04}"

 
}

resource "azurerm_virtual_machine_extension" "software" {
  depends_on=[azurerm_windows_virtual_machine.main]

  name                       = "install-gpmc"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
       "commandToExecute": "powershell.exe -Command \"${local.powershell}\""
 
   }
  SETTINGS
}


resource "random_password" "set_password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}



<powershell>
#Ajustar time zone
Set-TimeZone -Name "E. South America Standard Time"

# Desativar para usuários administradores
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

# Desativar para todos os outros usuários
$UserKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer"
$UserValueName = "IEHarden"
Set-ItemProperty -Path $UserKeyPath -Name $UserValueName -Value 0

#Alterar o Hostname
Rename-Computer -NewName "AD"

Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools
Import-Module ADDSDeployment, DnsServer

# Criar um Arquivo
$conteudoContinuacao = @"
Install-ADDSForest -DomainName "rbarozzi.local" -DomainNetbiosName "rbarozzi" -DomainMode WinThreshold -ForestMode WinThreshold -DatabasePath "C:/Windows/NTDS" -SysvolPath "C:/Windows/SYSVOL" -LogPath "C:/Windows/NTDS" -NoRebootOnCompletion:`$false -Force:`$true -SafeModeAdministratorPassword (ConvertTo-SecureString 'Raf!1Ab19uI0923' -AsPlainText -Force)
Unregister-ScheduledTask -TaskName "ContinuacaoAposReinicio" -Confirm:`$false
"@

$conteudoContinuacao | Set-Content -Path "C:\continuacao.ps1"

# Criar uma tarefa agendada para a continuação após o reinício
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File 'C:\continuacao.ps1'"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "ContinuacaoAposReinicio"

# Reiniciar a instância
Restart-Computer -Force
</powershell>
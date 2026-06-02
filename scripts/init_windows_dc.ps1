<powershell>
Rename-Computer -NewName "WIN-SERVER-DC" -Force
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
$Password = ConvertTo-SecureString "Educacion.2024!" -AsPlainText -Force
Install-ADDSForest `
  -CreateDnsDelegation:$false `
  -DomainMode "WinThreshold" `
  -DomainName "portcastello.local" `
  -DomainNetbiosName "PORTCASTELLO" `
  -ForestMode "WinThreshold" `
  -InstallDns:$true `
  -SafeModeAdministratorPassword $Password `
  -Force
Restart-Computer -Force
</powershell>

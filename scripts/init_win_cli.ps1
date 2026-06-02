<powershell>
Rename-Computer -NewName "WIN-CLI" -Force
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Restart-Computer -Force
</powershell>

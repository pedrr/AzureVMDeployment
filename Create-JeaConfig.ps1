# for logs of our “half-admin” actions performed in his session. This is a nice feature of PowerShell and using it definitely makes sense.
md “$env:ProgramData\JEAConfiguration\Transcripts”

# for the module responsible for doing all the magic here
md “$env:ProgramFiles\WindowsPowerShell\Modules\Demo_Module\RoleCapabilities” 

# create module manifest
New-ModuleManifest -Path “$env:ProgramFiles\WindowsPowerShell\Modules\Demo_Module\Demo_Module.psd1”

# Create Role Capabilities

$MaintenanceRoleCapabilityCreationParams = @{
   Author = ‘infoWAN Admin’
   CompanyName = ‘soliver’
   VisibleCmdlets = ‘Restart-Service’
   FunctionDefinitions =
           @{ Name = ‘Get-UserInfo’; ScriptBlock = { $PSSenderInfo } }
}

# create capability file
New-PSRoleCapabilityFile -Path “$env:ProgramFiles\WindowsPowerShell\Modules\Demo_Module\RoleCapabilities\Maintenance.psrc” @MaintenanceRoleCapabilityCreationParams

# create *.pssc (PowerShell Session Configuration) file skeleton:
New-PSSessionConfigurationFile -Path “$env:ProgramData\JEAConfiguration\JEADemo2.pssc”

<#
In line 16: # SessionType = ‘Default’ → SessionType = ‘RestrictedRemoteServer’
In line 19: # TranscriptDirectory = ‘C:\Transcripts\’ → TranscriptDirectory = “C:\ProgramData\JEAConfiguration\Transcripts”
In line 22: # RunAsVirtualAccount = $true → RunAsVirtualAccount = $true
In line 28: #RoleDefinitions = @{ ‘CONTOSO\SqlAdmins’ = @{ RoleCapabilities = ‘SqlAdministration’ }; ‘CONTOSO\ServerMonitors’ = @{ VisibleCmdlets = ‘Get-Process’ } } →
RoleDefinitions = @{SOliver\JEAdmins’ = @{ RoleCapabilities =  ‘Maintenance’ }}
#>

# Now you can easily register the session configuration by typing:

Register-PSSessionConfiguration -Name ‘JEADemo2’ -Path “$env:ProgramData\JEAConfiguration\JEADemo2.pssc”
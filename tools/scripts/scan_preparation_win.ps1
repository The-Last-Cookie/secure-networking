# requires -RunAsAdministrator
# requires -Version 5.0
# As admin: powershell.exe -ExecutionPolicy RemoteSigned

. .\UACModule.ps1
. .\RemoteRegistryModule.ps1

Write-Host "Nessus scan readiness check"
Write-Host "---------------------------`n"

$LocalHost = [Environment]::MachineName
$LocalDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
Write-Host "Check executing for $LocalHost, part of $LocalDomain"

Write-Host "This script will now go over every setting that is relevant for a Nessus scan."
Write-Host "Keep in mind that not setting every configuration to its required value may impact the scan.`n"

HandleUserAccountControl
#EnableRemoteRegistry

Write-Host "The system has been prepared for the scan."

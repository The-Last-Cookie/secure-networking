# requires -RunAsAdministrator
# requires -Version 5.0
# As admin: powershell.exe -ExecutionPolicy RemoteSigned

. .\Modules\UACModule.ps1
. .\Modules\RemoteRegistryModule.ps1
. .\Modules\WmiModule.ps1

function Get-Report
{
	# create table from config file
}

function Start-Check
{
	Write-Host "This script will now go over every setting that is relevant for a Nessus scan."
	Write-Host "Keep in mind that not setting every configuration to its required value may impact the scan.`n"

	HandleUserAccountControl

	Write-Host ""

	HandleRemoteRegistry

	Write-Host ""

	HandleWMI

	Write-Host ""

	#HandlePrinterSharing

	Write-Host "The system has been prepared for the scan."
}

Write-Host "Nessus scan readiness check"
Write-Host "---------------------------`n"

$LocalHost = [Environment]::MachineName
$LocalDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
Write-Host "Script executing for $LocalHost, part of $LocalDomain"

Start-Check

# requires -RunAsAdministrator
# requires -Version 5.0
# As admin: powershell.exe -ExecutionPolicy RemoteSigned

. .\Modules\UACModule.ps1
. .\Utils\RegistryUtils.ps1
. .\Utils\FileUtils.ps1

function UserAccountControl
{
	param
	(
		$Configuration
	)

	$RegistryItem = "LocalAccountTokenFilterPolicy"
	if ($Configuration.LocalAccountTokenFilterPolicy -match "NoValueException") {
		Remove-ItemProperty -Path $SystemPolicies -Name $RegistryItem
	}
	else {
		Set-RegistryValue -Key $SystemPolicies -Name $RegistryItem -Value $Configuration.LocalAccountTokenFilterPolicy
	}

	Set-UACLevel -Level $Configuration.UACLevel
}

function RemoteRegistry
{
	param
	(
		$Configuration
	)

	Stop-Service -InputObject (Get-Service -ComputerName $Configuration.Computer -Name RemoteRegistry) -ErrorAction Stop
	Set-Service -ComputerName $Configuration.Computer -Name RemoteRegistry -StartupType Disabled -ErrorAction Stop
}

function Restore-Setting
{
	param
	(
		[string] $Key,
		$Configuration
	)

	switch ($Key) {
		"uac" {
			UserAccountControl -Configuration $Configuration
		}

		"remote-registry" {
			RemoteRegistry -Configuration $Configuration
		}
	}
}

Write-Host "Nessus scan cleanup"
Write-Host "---------------------------`n"

$LocalHost = [Environment]::MachineName
$LocalDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
Write-Host "Script executing for $LocalHost, part of $LocalDomain"

Write-Host "Reverting changes to system default.`n"

$Settings = Get-Settings
if ($null -eq $Settings) {
	Write-Host "No settings file found.`nExiting."
	Exit
}

$Settings = Get-Hashtable $Settings
$Keys = $Settings.Keys

foreach ($Key in $Keys) {
	$Setting = $Settings.$Key
	Restore-Setting -Key $Key -Configuration $Setting
}

Remove-Item .\config.json

Write-Host "System default has been restored."

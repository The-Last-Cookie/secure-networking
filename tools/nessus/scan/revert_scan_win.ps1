# requires -RunAsAdministrator
# requires -Version 5.0
# As admin: powershell.exe -ExecutionPolicy RemoteSigned

. .\Modules\UACModule.ps1
. .\Utils\RegistryUtils.ps1
. .\Utils\FileUtils.ps1
. .\Utils\Enums.ps1

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

	$RemoteRegistry = Get-Service -ComputerName $Configuration.Computer -Name RemoteRegistry

	Set-Service -ComputerName $Configuration.Computer -Name RemoteRegistry -StartupType $Configuration.StartType -ErrorAction Stop
	$StartType = ([ServiceStartupType]$Configuration.StartType).ToString()
	Write-Host "$($Configuration.Computer): Setting startup type of remote registry to $StartType"

	if ($RemoteRegistry.Status -eq [ServiceControllerStatus]::Running -and $Configuration.Status -eq [ServiceControllerStatus]::Stopped) {
		Write-Host "$($Configuration.Computer): Stopping remote registry"
		Stop-Service -InputObject ($RemoteRegistry) -ErrorAction Stop
		return
	}

	if ($RemoteRegistry.Status -eq [ServiceControllerStatus]::Stopped -and $Configuration.Status -eq [ServiceControllerStatus]::Running) {
		Write-Host "$($Configuration.$Computer): Starting remote registry"
		Start-Service -InputObject ($RemoteRegistry) -ErrorAction Stop
	}
}

function WMI
{
	param
	(
		$Configuration
	)

	$WMI = Get-Service -ComputerName $Configuration.Computer -Name Winmgmt

	Set-Service -ComputerName $Configuration.Computer -Name Winmgmt -StartupType $Configuration.StartType -ErrorAction Stop
	$StartType = ([ServiceStartupType]$Configuration.StartType).ToString()
	Write-Host "$($Configuration.Computer): Setting startup type of WMI to $StartType"

	if ($WMI.Status -eq [ServiceControllerStatus]::Running -and $Configuration.Status -eq [ServiceControllerStatus]::Stopped) {
		Write-Host "$($Configuration.Computer): Stopping WMI"
		Stop-Service -InputObject ($WMI) -ErrorAction Stop
		return
	}

	if ($WMI.Status -eq [ServiceControllerStatus]::Stopped -and $Configuration.Status -eq [ServiceControllerStatus]::Running) {
		Write-Host "$($Configuration.$Computer): Starting WMI"
		Start-Service -InputObject ($WMI) -ErrorAction Stop
	}
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
		"wmi" {
			WMI -Configuration $Configuration
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

Write-Host "`nSystem default has been restored."

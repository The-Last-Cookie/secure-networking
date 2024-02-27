Import-Module .\Utils\TextUtils.ps1

function EnableRemoteRegistry
{
	param (
		[string] $Computer = [Environment]::MachineName
	)

	try {
		$RemoteRegistry = Get-Service -ComputerName $Computer -Name RemoteRegistry

		if ($RemoteRegistry.Status -eq 'Running') {
			Write-Host "$($Computer): Remote registry is already enabled"
			return
		}

		if ($RemoteRegistry.StartType -eq 'Disabled') {
			Set-Service -ComputerName $Computer -Name RemoteRegistry -StartupType Automatic -ErrorAction Stop
			Write-Host "$($Computer): Remote registry has been enabled"
		}

		if ($RemoteRegistry.Status -eq 'Stopped') {
			Start-Service -InputObject (Get-Service -ComputerName $Computer -Name RemoteRegistry) -ErrorAction Stop
			Write-Host "$($Computer): Remote registry has been started"
		}
	} catch {
		Write-Host $_.Exception.Message
	}

    Write-BulletPoint -Text "Remote registry active"
}

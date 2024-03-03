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

function HandleRemoteRegistry
{
	param (
		$Silent = $false
	)

	$Computer = [Environment]::MachineName
	$RemoteRegistry = Get-Service -ComputerName $Computer -Name RemoteRegistry

	if ($RemoteRegistry.Status -eq 'Running') {
		Write-BulletPoint "Remote registry configuration is correct."
		return
	}

	$RemoteRegistryConfig = @{
		"remote-registry" = @{
			"Computer" = $Computer
		}
	}
	Save-Setting -Content $RemoteRegistryConfig

	if (!$Silent) {
		$Answer = Read-Host -Prompt "Remote registry is currently disabled. Press 'y' to enable it. "
		if ($Answer -match "y") {
			EnableRemoteRegistry
		} else {
			Write-Host "Skipping remote registry configuration."
			return
		}
	}

	EnableRemoteRegistry
}

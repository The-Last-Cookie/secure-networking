Import-Module .\Utils\TextUtils.ps1

function EnableWMI
{
	param (
		[string] $Computer = [Environment]::MachineName
	)

	try {
		$WMI = Get-Service -ComputerName $Computer -Name Winmgmt

		if ($WMI.Status -eq 'Running') {
			Write-Host "$($Computer): WMI is already enabled"
			return
		}

		if ($WMI.StartType -eq 'Disabled') {
			Set-Service -ComputerName $Computer -Name Winmgmt -StartupType Automatic -ErrorAction Stop
			Write-Host "$($Computer): WMI has been enabled"
		}

		if ($WMI.Status -eq 'Stopped') {
			Start-Service -InputObject (Get-Service -ComputerName $Computer -Name Winmgmt) -ErrorAction Stop
			Write-Host "$($Computer): WMI has been started"
		}
	} catch {
		Write-Host $_.Exception.Message
	}

    Write-BulletPoint -Text "WMI active"
}

function HandleWMI
{
	param (
		$Silent = $false
	)

	$Computer = [Environment]::MachineName
	$WMI = Get-Service -ComputerName $Computer -Name Winmgmt

	if ($WMI.Status -eq 'Running') {
		Write-BulletPoint -Text "WMI configuration is correct."
		return
	}

	$WMIConfig = @{
		"wmi" = @{
			"Computer" = $Computer
			"StartType" = $WMI.StartType
			"Status" = $WMI.Status
		}
	}
	Save-Setting -Content $WMIConfig

	if ($Silent) {
		EnableWMI
		return
	}

	$Answer = Read-Host -Prompt "WMI is currently disabled. Press 'y' to enable it. "
	if ($Answer -match "y") {
		EnableWMI
	} else {
		Write-Host "Skipping WMI configuration."
	}
}

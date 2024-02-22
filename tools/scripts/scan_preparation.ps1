# requires -RunAsAdministrator
# requires -Version 5.0
# As admin: powershell.exe -ExecutionPolicy RemoteSigned

Import-Module .\TextUtils.ps1
Import-Module .\RegistryUtils.ps1

$SystemPolicies = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin"
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop"

function Get-UACLevel {
    $ConsentPromptBehaviorAdmin_Value = Get-RegistryValue -Key $SystemPolicies -Name $ConsentPromptBehaviorAdmin_Name
    $PromptOnSecureDesktop_Value = Get-RegistryValue -Key $SystemPolicies -Name $PromptOnSecureDesktop_Name

    if ($ConsentPromptBehaviorAdmin_Value -eq 0 -and $PromptOnSecureDesktop_Value -eq 0) {
        return "[Level 0] Never notify"
    }
    elseif ($ConsentPromptBehaviorAdmin_Value -eq 5 -and $PromptOnSecureDesktop_Value -eq 0) {
        return "[Level 1] Notify me only when apps try to make changes to my computer (do not dim my desktop)"
    }
    elseif ($ConsentPromptBehaviorAdmin_Value -eq 5 -and $PromptOnSecureDesktop_Value -eq 1) {
        return "[Level 2] Notify me only when apps try to make changes to my computer (default)"
    }
    elseif ($ConsentPromptBehaviorAdmin_Value -eq 2 -and $PromptOnSecureDesktop_Value -eq 1) {
       return "[Level 3] Always notify"
    }
    else {
        return "Unknown"
    }
}

function Set-UACLevel {
    param (
		[int] $Level = 2
	)

    if($Level -notin 0, 1, 2, 3) {
		"No supported level"
		return
	}
	
    $ConsentPromptBehaviorAdmin_Value = 5
    $PromptOnSecureDesktop_Value = 1

    switch($Level)
    {
      0 {
          $ConsentPromptBehaviorAdmin_Value = 0
          $PromptOnSecureDesktop_Value = 0
      }
      1 {
          $ConsentPromptBehaviorAdmin_Value = 5
          $PromptOnSecureDesktop_Value = 0
      }
      2 {
          $ConsentPromptBehaviorAdmin_Value = 5
          $PromptOnSecureDesktop_Value = 1
      }
      3 {
          $ConsentPromptBehaviorAdmin_Value = 2
          $PromptOnSecureDesktop_Value = 1
      }
    }

    Set-RegistryValue -Key $SystemPolicies -Name $ConsentPromptBehaviorAdmin_Name -Value $ConsentPromptBehaviorAdmin_Value
    Set-RegistryValue -Key $SystemPolicies -Name $PromptOnSecureDesktop_Name -Value $PromptOnSecureDesktop_Value
}

function DisableUserAccountControl
{
	Set-RegistryValue -Key $SystemPolicies -Name "LocalAccountTokenFilterPolicy" -Value 1
	Set-UACLevel -Level 0

    Write-BulletPoint -Text "LocalAccountTokenFilterPolicy set to 1"
    Write-BulletPoint -Text "UAC level set to: $(Get-UACLevel)"
}

function EnableRemoteRegistry
{
	param (
		[string] $Computer = $env:COMPUTERNAME
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

function ActivateAdministrativeShares
{
	#[CmdletBinding()]
	#param (
	#	[Parameter()]
	#	[TypeName]
	#	$ParameterName
	#)

    # Disable-NetAdapterBinding -Name [name] -DisplayName "Datei- und Druckerfreigabe für Microsoft-Netzwerke"
    # does not work seemingly? the UI setting does not change

    # netsh advfirewall firewall set rule group="File and Printer sharing" new enable=False
    # maybe
}

Write-Host "Nessus scan readiness check"
Write-Host "---------------------------`n"

#DisableUserAccountControl
#EnableRemoteRegistry
#ActivateAdministrativeShares

Write-Host "The system has been prepared for the scan."

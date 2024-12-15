. .\Utils\TextUtils.ps1
. .\Utils\RegistryUtils.ps1
. .\Utils\FileUtils.ps1

$CurrentVersion = "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion"
$SystemPolicies = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin"
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop"

enum UACState {
	Unknown = -1
	NeverNotify = 0
	NotifyDoNotDimDesktop = 1
	NotifyDefault = 2
	AlwaysNotify = 3
}

function Get-UACStateText
{
	param(
		[int] $State = -1
	)

	switch ($State)
	{
		-1 { return "Unknown" }
		0 { return "[Level 0] Never notify" }
		1 { return "[Level 1] Notify me only when apps try to make changes to my computer (do not dim my desktop)" }
		2 { return "[Level 2] Notify me only when apps try to make changes to my computer (default)" }
		3 { return "[Level 3] Always notify" }
	}
}

function Get-UACLevel {
    $ConsentPromptBehaviorAdmin_Value = Get-RegistryValue -Key $SystemPolicies -Name $ConsentPromptBehaviorAdmin_Name
    $PromptOnSecureDesktop_Value = Get-RegistryValue -Key $SystemPolicies -Name $PromptOnSecureDesktop_Name

    if ($ConsentPromptBehaviorAdmin_Value -eq 0 -and $PromptOnSecureDesktop_Value -eq 0) {
        return [UACState]::NeverNotify
    }
    elseif ($ConsentPromptBehaviorAdmin_Value -eq 5 -and $PromptOnSecureDesktop_Value -eq 0) {
        return [UACState]::NotifyDoNotDimDesktop
    }
    elseif ($ConsentPromptBehaviorAdmin_Value -eq 5 -and $PromptOnSecureDesktop_Value -eq 1) {
        return [UACState]::NotifyDefault
    }
    elseif ($ConsentPromptBehaviorAdmin_Value -eq 2 -and $PromptOnSecureDesktop_Value -eq 1) {
       return [UACState]::AlwaysNotify
    }
    else {
        return [UACState]::Unknown
    }
}

function Set-UACLevel {
    param (
		[int] $Level = 2
	)

    if ($Level -notin 0, 1, 2, 3) {
		"No supported level"
		return
	}
	
    $ConsentPromptBehaviorAdmin_Value = 5
    $PromptOnSecureDesktop_Value = 1

    switch ($Level)
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

function Disable-UserAccountControl
{
	Write-Host "Enable remote login for administrator accounts"
	Set-RegistryValue -Key $SystemPolicies -Name "LocalAccountTokenFilterPolicy" -Value 1
	Write-Host "LocalAccountTokenFilterPolicy set to 1"

	# For Windows 7 and 8, "EnableLua" must be set to 0
	$OS_Name = (gcim Win32_OperatingSystem).Caption
	$OS_Release = Get-RegistryValue -Key $CurrentVersion -Name "ReleaseID"

	if ($OS_Release -match "^6\.1\." -or $OS_Release -match "^6\.[23]\.") {
		Write-Host "Detected $OS_Name (Version: $OS_Release)"
		Set-RegistryValue -Key $SystemPolicies -Name "EnableLua" -Value 0
		Write-BulletPoint -Text "EnableLua set to 0"
	}

	Set-UACLevel -Level 0
	$UACLevelText = Get-UACStateText (Get-UACLevel)
	Write-Host "UAC level set to: $UACLevelText"

	Write-BulletPoint -Text "User Account Control (UAC) disabled"
}

function HandleUserAccountControl
{
	param (
		$Silent = $false
	)

	$LocalAccountTokenFilterPolicy = Get-RegistryValue -Key $SystemPolicies -Name "LocalAccountTokenFilterPolicy"
	$EnableLua = Get-RegistryValue -Key $SystemPolicies -Name "EnableLua"

	if (($LocalAccountTokenFilterPolicy -eq 1) -and ((Get-UACLevel) -eq [UACState]::NeverNotify)) {
		if ($EnableLua -eq 1) {
			# todo: handle enablelua for windows 8 and 10
			Write-BulletPoint -Text "UAC configuration is correct."
			return
		}
	}

	$UACConfiguration = @{
		"uac" = @{
			"EnableLua" = $EnableLua
			"LocalAccountTokenFilterPolicy" = $LocalAccountTokenFilterPolicy
			"UACLevel" = Get-UACLevel
		}
	}
	Save-Setting -Content $UACConfiguration

	if ($Silent) {
		Disable-UserAccountControl
		return
	}

	$Answer = Read-Host -Prompt "User Account Control (UAC) is currently enabled. Press 'y' to disable it. "
	if ($Answer -match "y") {
		Disable-UserAccountControl
	} else {
		Write-Host "Skipping UAC configuration."
	}
}

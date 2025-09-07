Import-Module .\Utils\TextUtils.ps1

function Get-FWStatus
{
	param
	(
		$DisplayName,
		$FWProfile
	)

	Get-NetFirewallRule -DisplayName $DisplayName -PolicyStore ActiveStore | Where-Object Direction -eq Inbound | Where-Object Profile -eq $($FWProfile.Name) | Where-Object Action -match Allow | Where-Object Enabled -eq True
}

function Get-FWAllStatus
{
	param
	(
		$DisplayName
	)

	Get-NetFirewallRule -DisplayName $DisplayName -PolicyStore ActiveStore | Where-Object Direction -eq Inbound | Where-Object Action -match Allow | Where-Object Enabled -eq True
}

function ValidateFirewall
{
	$FWService = Get-Service -DisplayName "Windows Defender Firewall"
	# or -Name "mpssvc"

	#$FWSMBInName = "File and Printer Sharing (SMB-In)"
	$FWSMBInName = "Datei- und Druckerfreigabe (SMB eingehend)"

	if ($FWService.Status -ne "Running") {
		return $true
	}

	$FWProfiles = Get-NetFirewallProfile
	$fwIssueFound = $false

	foreach ($FWProfile in $FWProfiles) {
		if ($FWProfile.Enabled) {
			$FWSMBInStatus = Get-FWStatus -DisplayName $FWSMBInName -FWProfile $FWProfile
			$FWSMBInAllStatus = Get-FWAllStatus -DisplayName $FWSMBInName

			if (!$FWSMBInStatus -And !$FWSMBInAllStatus) {
				#Write-Host "The $($FWProfile.Name) profile doesn't have $FWSMBInName enabled. This is required."
				$fwIssueFound = $true
			}
		}
		#else {
		#    Write-Host "The Windows Firewall $($FWProfile.Name) profile is disabled; skipping checks."
		#}

		#Write-Host ""
	}

	if ($fwIssueFound) {
		return $false
	}

	return $true
}

function EnablePrinterSharing
{
	#$DisplayGroup "Printer and file sharing"
	$DisplayGroup = "Datei- und Druckerfreigabe"
	Set-NetFirewallRule -DisplayGroup $DisplayGroup -Enabled True -Profile Private
	Write-BulletPoint -Text "Printer sharing active"
}

function HandlePrinterSharing
{
	param (
		$Silent = $false
	)

	Write-Host "Checking firewall for printer sharing."
	if (ValidateFirewall) {
		Write-BulletPoint -Text "Printer sharing configuration is correct."
		return
	}

	$PrinterSharing = @{
		"printer-sharing" = @{
			"Computer" = [Environment]::MachineName
			"PrinterSharing" = $false
		}
	}
	Save-Setting -Content $PrinterSharing

	if ($Silent) {
		EnablePrinterSharing
		return
	}

	$Answer = Read-Host -Prompt "Printer sharing is currently disabled. Press 'y' to enable it. "
	if ($Answer -match "y") {
		EnablePrinterSharing
	} else {
		Write-Host "Skipping printer sharing configuration."
	}
}

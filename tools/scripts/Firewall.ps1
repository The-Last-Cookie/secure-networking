# Requires German system setting

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

$FWServices = Get-Service -Name "mpssvc"
$fwIssueFound = 0

#$FWDcomInName = "Windows Management Instrumentation (DCOM-In)"
#$FWWmiInName = "Windows Management Instrumentation (WMI-In)"
#$FWASyncInName = "Windows Management Instrumentation (ASync-In)"
#$FWSMBInName = "File and Printer Sharing (SMB-In)"

$FWDcomInName = "Windows-Verwaltungsinstrumentation (DCOM eingehend)"
$FWWmiInName = "Windows-Verwaltungsinstrumentation (WMI eingehend)"
$FWASyncInName = "Windows-Verwaltungsinstrumentation (ASync eingehend)"
$FWSMBInName = "Datei- und Druckerfreigabe (SMB eingehend)"

foreach ($FWService in $FWServices) {
	if ($FWService.Status -eq "Running") {
		$FWProfiles = Get-NetFirewallProfile

		foreach ($FWProfile in $FWProfiles) {
			if ($FWProfile.Enabled -eq 1) {
				$FWDcomInStatus = Get-FWStatus -DisplayName $FWDcomInName -FWProfile $FWProfile
				$FWDcomInAllStatus = Get-FWAllStatus -DisplayName $FWDcomInName
				if (!$FWDcomInStatus -and !$FWDcomInAllStatus) {
					Write-Host "The $($FWProfile.Name) profile doesn't have $FWDcomInName enabled. This is required."
					$fwIssueFound = 1
				}

				$FWWmiInStatus = Get-FWStatus -DisplayName $FWWmiInName -FWProfile $FWProfile
				$FWWmiInAllStatus = Get-FWAllStatus -DisplayName $FWWmiInName
				If(!$FWWmiInStatus -and !$FWWmiInAllStatus) {
					Write-Host "The $($FWProfile.Name) profile doesn't have $FWWmiInName enabled. This is required."
					$fwIssueFound = 1
				}

				$FWASyncInStatus = Get-FWStatus -DisplayName $FWASyncInName -FWProfile $FWProfile
				$FWASyncInAllStatus = Get-FWAllStatus -DisplayName $FWASyncInName
				if (!$FWASyncInStatus -and !$FWASyncInAllStatus) {
					Write-Host "The $($FWProfile.Name) profile doesn't have $FWASyncInName enabled. This is required."
					$fwIssueFound = 1
				}

				$FWSMBInStatus = Get-FWStatus -DisplayName $FWSMBInName -FWProfile $FWProfile
				$FWSMBInAllStatus = Get-FWAllStatus -DisplayName $FWSMBInName
				if (!$FWSMBInStatus -And !$FWSMBInAllStatus) {
					Write-Host "The $($FWProfile.Name) profile doesn't have $FWSMBInName enabled. This is required."
					$fwIssueFound = 1
				}
			}
			#else {
			#    Write-Host "The Windows Firewall $($FWProfile.Name) profile is disabled; skipping checks."
			#}
		}

		if ($fwIssueFound -ne 1) {
			"No changes needed. Correct configuration."
		}
		else {
			Write-Host "`nNote: This is auditing the minimum required built-in firewall rules as described in the documentation below. It does not check for custom rules or third-party firewall configurations. As such, the results above should be validated with the action taken to allow Nessus through the local firewall."
			Write-Host "See also https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm"
		}
	}
	else {
		Write-Host "The $($FWService.DisplayName) service is stopped; skipping checks."
	}
}

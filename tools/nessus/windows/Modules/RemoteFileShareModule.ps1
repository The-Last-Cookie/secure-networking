Import-Module .\Utils\TextUtils.ps1

function HandleRemoteFileShares
{
	$Shares = Get-SmbServerConfiguration | Select-Object AutoShareServer,AutoShareWorkstation

	if ($Shares.AutoShareServer -eq $True -and $Shares.AutoShareServer -eq $True) {
		Write-BulletPoint -Text "Remote file share configuration is correct."
		return
	}

	Write-BulletPoint -Text "Remote file share configuration is not correct." -State 1
	Write-Host "The remote file shares are currently deactivated. By default, they should be active."
	Write-Host "Please verify your configuration."
	Write-Host "Skipping remote file share configuration."
}

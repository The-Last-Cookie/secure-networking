function Write-BulletPoint
{
	param
	(
		[string] $Prefix = "[",
		[string] $Suffix = "] ",
		[string] $Text = "Done",
		[int] $State = 0
	)

	if ($State -notin 0, 1, 2) {
		return
	}

	$greenCheck = @{
		Object = [char] 8730
		ForegroundColor = 'Green'
		NoNewLine = $true
	}

	$redCheck = @{
		Object = 'X'
		ForegroundColor = 'Red'
		NoNewLine = $true
	}

	Write-Host $Prefix -NoNewLine

	if ($State -eq 0) {
		Write-Host @greenCheck
	}
	elseif ($State -eq 1) {
		Write-Host @redCheck
	}
	elseif ($State -eq 2) {
		Write-Host " " -NoNewline
	}

	Write-Host $Suffix -NoNewline
	Write-Host $Text
}

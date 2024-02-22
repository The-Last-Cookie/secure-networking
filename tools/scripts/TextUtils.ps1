function Write-BulletPoint
{
	param
	(
		[string] $Prefix = "[",
		[string] $Suffix = "] ",
		[string] $Text = "Done",
		$Done = $true
	)

	$greenCheck = @{
		Object = [char] 8730
		ForegroundColor = 'Green'
		NoNewLine = $true
	}

	Write-Host $Prefix -NoNewLine

	if ($Done) {
		Write-Host @greenCheck
	}
	else {
		Write-Host " " -NoNewline
	}

	Write-Host $Suffix -NoNewline
	Write-Host $Text
}

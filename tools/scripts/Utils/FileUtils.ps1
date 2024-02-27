function Save-Setting
{
	param (
		$Content,
		$Path = ".\config.json"
	)

	try {
		$myJson = Get-Content $Path -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
	} catch {
		$myJson = @{}
	}

	$myJson += $Content
	$myJson | ConvertTo-Json | Out-File $Path
}

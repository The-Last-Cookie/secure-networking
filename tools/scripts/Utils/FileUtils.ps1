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

	# Everything for one check is contained in one key
	$Key = $Content.Keys[0]
	$myJson[$Key] += $Content
	$myJson | ConvertTo-Json | Out-File $Path
}

function Get-Settings
{
	param (
		$Path = ".\config.json"
	)

	Get-Content $Path -Raw | ConvertFrom-Json
}

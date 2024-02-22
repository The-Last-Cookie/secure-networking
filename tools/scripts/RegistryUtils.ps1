function Set-RegistryValue
{
	param (
		[string] $Key,
		[string] $Name,
		[string] $Value,
		[string] $Type = "DWORD"
	)

	if ((Test-Path -Path $Key) -eq $false) { New-Item -ItemType Directory -Path $Key | Out-Null }
	Set-ItemProperty -Path $Key -Name $Name -Value $Value -Type $Type
}

function Get-RegistryValue
{
	param (
		[string] $Key,
		[string] $Name
	)

	Get-ItemPropertyValue $Key $Name
}

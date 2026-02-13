function Get-Hashtable {
    param (
        $value
    )

    $result = $null
    if ($value -is [System.Management.Automation.PSCustomObject])
    {
        $result = @{}
        $value.psobject.properties | ForEach-Object {
            $result[$_.Name] = Get-Hashtable -value $_.Value
        }
    }
    elseif ($value -is [System.Object[]])
    {
        # TODO: Fix empty lists being returned as null?
        $list = New-Object System.Collections.ArrayList
        $value | ForEach-Object {
            $list.Add((Get-Hashtable -value $_)) | Out-Null
        }
        $result = $list
    }
    else
    {
        $result = $value
    }

    return $result
}

function Save-Setting
{
	param (
		$Content,
		$Path = ".\config.json"
	)

    $Settings = Get-Content $Path -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json

    # Not sure how to handle this with PSCustomObject
    $Settings = Get-Hashtable -Value $Settings
    $Content = Get-Hashtable $Content
    if ($Settings.count -eq 0) {
        $Settings = @{}
    }

    # Add configuration to current settings
    # Everything for one check is contained in one key
    $Key = @($Content.Keys)[0]
    $Settings.$Key = $Content.$Key
    $Settings | ConvertTo-Json | Out-File $Path
}

function Get-Settings
{
	param (
		$Path = ".\config.json"
	)

	Get-Content $Path -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
}

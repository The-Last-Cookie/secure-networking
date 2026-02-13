# Notes

## Ideas

What I imagine for this script in the future:

- Command line option "report" creates a file report.txt containing a table with what was changed (in simple terms). Not every single registry key is listed but rather what was configured in general. So instead of saying `LocalAccountTokenFilterPolicy` was set to 1, it just says *UAC was disabled*.
- A `settings.json` file is created containing every single setting (now seen from the technical layer). The cleanup script could use that to more easily retrieve the system's default settings (before the scan).
- Let the user go through every check and let them choose to apply recommended/required settings or not.
  - Command line option "silent"/"force" will not ask the user.

## Missing checks?

### Enable admin remote file shares (client and server)

*Notice: Restart required for changes to take effect.*

Nessus needs access to remote file shares like C$ and ADMIN$.

Set AutoShareServer and AutoShareWks in `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters` to 1 or remove them.

```ps
Get-SmbServerConfiguration | Select AutoShareServer,AutoShareWorkstation

# Enable
Set-SmbServerConfiguration -AutoShareServer $True -AutoShareWorkstation $True -Confirm:$false

# Disable
Set-SmbServerConfiguration -AutoShareServer $False -AutoShareWorkstation $False -Confirm:$false
```

### Network logons

*Notice: This setting is only required when scanning Windows XP. Scans for Windows 7 and above use `LocalAccountTokenFilterPolicy`.[^force-guest]*

Ensure 'Network access: Sharing and security model for local accounts' is set to 'Classic - local users authenticate as themselves'.

Set ForceGuest in `HKEY_LOCAL_MACHINE\System\Currentcontrolset\Control\Lsa` to 0

This policy setting determines how network logons that use local accounts are authenticated. The Classic option allows precise control over access to resources, including the ability to assign different types of access to different users for the same resource. This must be set to Classic for Nessus to have appropriate permissions to authenticate.

### Local administrator

Ensure the proper user/group is in the local Administrator group. For the scan, the nessus user must be part of the local admin group.

```ps
Get-LocalGroupMember -Group 'Administratoren'
```

### Windows 10 > 1709 - Server SPN Validation Enabled

On Windows 10 hosts, release 1709 and above, there have been reported issues with enabling Server SPN validation and credentialed Nessus scans.

```ps
# Simplify script by using RegistryUtils
try {
    $SPN_Validation = (Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters -Name SMBServerNameHardeningLevel).SMBServerNameHardeningLevel
}
catch {
    $SPN_Validation = 0
}

$OS_Name = (gcim Win32_OperatingSystem | Select-Object Name).Name

try {
    $OS_Release = (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseID
}
catch {
    $OS_Release = 0
}

if ((( $SPN_Validation -eq 1) -or ($SPN_Validation -eq 2)) -and ($OS_Name -match "Windows 10") -and ($OS_Release -ge 1709)) {"1"}
else {"0"}
```

## Annotations

[^force-guest]: [See here](https://github.com/kAh00t/Nessus-Powershell-Oneliners/blob/main/NessusOneLiners.md#confirm-forceguest-is-set-to-0-classic-is-required-for-nessus-seemingly---windows-xp-only-see-localaccounttokenfilterpolicy-for-win-7-and-above)

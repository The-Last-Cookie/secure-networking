# Notes

## Ideas

What I imagine for this script in the future:

- Command line option "report" creates a file report.txt containing a table with what was changed (in simple terms). Not every single registry key is listed but rather what was configured in general. So instead of saying `LocalAccountTokenFilterPolicy` was set to 1, it just says *UAC was disabled*.
- A `settings.json` file is created containing every single setting (now seen from the technical layer). The cleanup script could use that to more easily retrieve the system's default settings (before the scan).
- Let the user go through every check and let them choose to apply recommended/required settings or not.

## Missing checks?

### Enable remote file shares (client and server)

Nessus needs access to remote file shares like C$ and ADMIN$.

Set AutoShareServer and AutoShareWks in `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters` to 1 or remove them.

### Network logons

Ensure 'Network access: Sharing and security model for local accounts' is set to 'Classic - local users authenticate as themselves'.

Set ForceGuest in `HKEY_LOCAL_MACHINE\System\Currentcontrolset\Control\Lsa` to 0

This policy setting determines how network logons that use local accounts are authenticated. The Classic option allows precise control over access to resources, including the ability to assign different types of access to different users for the same resource. This must be set to Classic for Nessus to have appropriate permissions to authenticate.

### WMI

Check if WMI is activated

```ps
Set-Service -Name Winmgmt -StartupType Automatic
Start-Service -Name Winmgmt
```

### Lanman server

"Server" service must be on Automatic for administrative access.

### Local administrator

Ensure the proper user/group is in the local Administrator group. For the scan, the nessus user must be part of the local admin group.

```ps
$Filter = "Name = 'Administratoren'"
(Get-WMIObject Win32_Group -Filter $Filter).GetRelated("Win32_UserAccount") | Where-Object {$_.Domain -eq [Environment]::MachineName} | Select -exp Name
(Get-WMIObject Win32_Group -Filter $Filter).GetRelated("Win32_Group") | Where-Object {$_.Domain -eq [Environment]::MachineName} | Select -exp Name
(Get-WMIObject Win32_Group -Filter $Filter).GetRelated("Win32_UserAccount") | Where-Object {$_.Domain -ne [Environment]::MachineName} | Select -exp Caption
(Get-WMIObject Win32_Group -Filter $Filter).GetRelated("Win32_Group") | Where-Object {$_.Domain -ne [Environment]::MachineName} | Select -exp Caption
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

### Firewall

Firewall needs to be disabled (wf.msc)

Only needed for communication with VM?

```ps
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False
```

See also the preliminary script.

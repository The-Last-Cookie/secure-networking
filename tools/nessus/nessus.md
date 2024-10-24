# Vulnerability Management

Available programs: Tenable Nessus Essentials, OpenVAS, Holm Security, Qualys and Rapid 7.

For now, Tenable Nessus Essentials (from now on *Tenable*) will be used because it is free and seems to detect most of the common vulnerabilities on average. Also the user interface is pretty intuitive.

## Hardware requirements

- [System and License Requirements](https://docs.tenable.com/tenable-core/Nessus/Content/TenableCore/SystemRequirementsNessus.htm)
- [Tenable Nessus Scanner Hardware Requirements](https://docs.tenable.com/general-requirements/Content/NessusScannerHardwareRequirements.htm)

## Installation

*Notice: To use Nessus efficiently, it is recommend to use a Raspberry Pi 4 Model B with at least 8 GB RAM.*

1. Download the package file for the current version (`.deb`).
2. Install the package via `dpkg -i Nessus-10.0.0-raspberrypios_armhf.deb`.
3. Start the Nessus daemon with `/bin/systemctl start nessusd.service`.
4. Open Tenable in the browser with `https://<IP address>:8834`. Use *localhost* if the installation is done locally.
5. Perform the remaining Nessus installation steps in the browser.

## Usage

Tenable can be used for scanning up to 16 host devices. Discovery scans however support more than 16 IPs.[^0D53a00007ZjncaCAB]

The free version of Tenable does not support agent scanning, credentialed scanning is the only way when carrying out deep system analyses. Agents scans are part of the Nessus Manager paid version where the collected data can be send to e.g. [Tenable.sc](https://www.tenable.com/products/tenable-sc). On-site scans with local admin privileges will be able to analyse the system better than unprivileged scans or endpoint analysis. Endpoint scans which scan the host for open ports do have their own use though, which is to say that they can be used to detect unused services or critical connections to the network.

In this context, it is best to use static IPs for the host devices that should be scanned. Or, if possible, directly use the results from a discovery scan to execute a vulnerability scan for the discovered devices<!--TODO: Investigate if it is possible to reuse the scan results in such a way.-->.

## Running a credentialed scan

The scan should be done via a dedicated account used for scanning that has appropriate permissions (local administrator group). User accounts and admin accounts of users should not be used.

To store passwords for these dedicated accounts, Bitwarden might be useful to have on the server running Tenable.

### Considerations to take into account

- Log **monitoring** for when the account is in use outside of standard change control hours, with alerts for activities outside of normal windows.
- Perform frequent **password rotation** for privileged accounts more often than the "normal" internal standard.
- Enable accounts only when the time window for scans is active; **disable accounts** at other times.[^disable-account]
- On non-Windows systems, do not allow remote root logins. Configure your scans to **utilize escalation** such as su or sudo.
- (Use **key authentication** instead of password authentication.)

### Protecting credentials

#### Windows

There are a few best practices [outlined here](https://www.tenable.com/blog/5-ways-to-protect-scanning-credentials-for-windows-hosts) for an AD environment, however, this article only concerns computers that are not part of a domain.

#### Unix

- https://www.tenable.com/blog/5-ways-to-protect-scanning-credentials-for-linux-macos-and-unix-hosts

### Common Scan Failure Indicators

The scan may contain `Info` segments that contain indicators whether the scan executed successfully:

1. **WMI Not Available:** Indicates that WMI is either not enabled as a service on the target, or WMI-In is not enabled on the software firewall (see the sections Remote Registry, WMI and Firewall for more details).
2. **Nessus Scan Information (Plugin 19506)** contains the text `Credentialed checks: No`.
3. **Authentication Failure - Local Checks Not Run:** This often appears if the Remote Registry is not activated.
4. **Nessus Windows Scan Not Performed with Admin Privileges:** Most likely indicates that the administrative shares are not enabled or that the provided credentials do not belong to an admin account.

On the contrary, `WMI Available` and `Credentials checks: Yes` are a sign of a successful scan.

## Readiness check

### Windows

To enable a credentialed scan on **Windows**, the host device needs to be configured with certain settings.

The script in this project which applies this configuration automatically should only be used for computers that are not part of any domain.

To run the script, open PowerShell as admin, enter `powershell -ExecutionPolicy RemoteSigned` and run `scan_preparation_win.ps1`.

After the scan has completed successfully, `revert_scan_win.ps1` should be used to revert all changes.

Inspirations for these checks have been taken from [Nessus-Powershell-Oneliners](https://github.com/kAh00t/Nessus-Powershell-Oneliners/blob/main/NessusOneLiners.md) and [Nessus Credentialed Assessment Readiness Check (Windows)](https://github.com/tecnobabble/nessus_win_cred_test).

The following section details the required settings for a successful scan.

#### User account control (UAC)

Disable User Account Control (UAC) by setting it to `Never Notify`.[^uac]

Furthermore, add the registry key `LocalAccountTokenFilterPolicy` in `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` and set its value to 1.

#### Remote registry

In the `Services` dialogue (*services.msc*), remote registry must be activated (set to `Automatic`) so that Nessus can scan the system for insecure registry configurations.[^remote-registry]

#### Windows Management Instrumentation (WMI)

Like the remote registry, WMI must be active while scanning.

#### File and printer sharing

File and printer sharing needs to be activated for the scan.

*TODO: Commands need further testing before they can confidently be added as a standard routine in the script.*

```ps
Get-NetAdapterBinding -DisplayName "Datei- und Druckerfreigabe für Microsoft-Netzwerke"
Enable-NetAdapterBinding -DisplayName "Datei- und Druckerfreigabe für Microsoft-Netzwerke"
Disable-NetAdapterBinding -DisplayName "Datei- und Druckerfreigabe für Microsoft-Netzwerke"
```

#### smb stuff

TODO:

- <https://learn.microsoft.com/en-us/previous-versions/orphan-topics/ws.11/cc731957(v=ws.11)?redirectedfrom=MSDN>

Links from a Tenable blog page:

- https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858
- https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/microsoft-network-server-digitally-sign-communications-always
- https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-security

### Linux

**Linux** does support credentialed scans via SSH key authentication.

### Sources

- https://docs.tenable.com/nessus/Content/NessusCredentialedChecks.htm
- https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm
- https://docs.tenable.com/nessus/compliance-checks-reference/Content/CredentialedScanningandPrivilegedAccountUse.htm
- https://community.tenable.com/s/question/0D53a00006seVRHCA2/credentialed-scans-of-windows-10-workgroup-machines-with-nessus-essentials
- https://community.tenable.com/s/article/Scanning-with-non-default-Windows-Administrator-Account

## Managing Nessus

The service behind Nessus Essentials is called `nessusd` and its status can be retrieved via `service nessusd status`.

There is also the `/opt/nessus/sbin/nessuscli` tool to e.g. reset the password of the web interface.

### License activation

When not using Nessus for a long time or when the license expires, it may be that Nessus is not able to download the newest core update and the current plugin set. Upon trying to update Nessus via the terminal, the following message will appear:

```txt
Could not validate this preference file. Have installation files been copied from another system?
```

A new licence key may be obtained by visiting the [Tenable Nessus® Essentials](https://www.tenable.com/products/nessus/nessus-essentials) register page. An account creation is not required. A new licence key will be provided even if one submitted their name and mail address before.

Enter the new licence code in the `Settings` tab, under `Activation Code`. After that, Nessus needs to be [updated](#installing-updates).

### Installing updates

Before, it is recommended to make a backup with `/opt/nessus/sbin/nessuscli backup --create <name>`

```sh
sudo systemctl stop nessusd.service
sudo /opt/nessus/sbin/nessuscli update --all
sudo systemctl start nessusd.service
```

## Annotations

[^0D53a00007ZjncaCAB]: [Steve Gillham-1 in "Looking for clarification on Essentials 16 limit."](https://community.tenable.com/s/question/0D53a00007ZjncaCAB/looking-for-clarification-on-essentials-16-limit)
[^disable-account]: `net user <username> /active:no`. Activate again using the option *yes*.
[^uac]: In German, the dialogue is called "Einstellungen der Benutzerkontensteuerung ändern" and needs to be set from `Standard` to `Nie benachrichtigen`.
[^remote-registry]: In German, `Remoteregistrierung` must be set from `Deaktiviert` to `Automatisch`.

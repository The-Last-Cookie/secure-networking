# Vulnerability Management

Available programs: Tenable Nessus Essentials, OpenVAS, Holm Security, Qualys and Rapid 7.

For now, Tenable Nessus Essentials (from now on *Tenable*) will be used because it is free and seems to detect most of the common vulnerabilities on average. Also the user interface is pretty intuitive.

## Hardware requirements

- [System and License Requirements](https://docs.tenable.com/tenable-core/Nessus/Content/TenableCore/SystemRequirementsNessus.htm)
- [Tenable Nessus Scanner Hardware Requirements](https://docs.tenable.com/general-requirements/Content/NessusScannerHardwareRequirements.htm)

## Installation

*Notice: To use Nessus efficiently, it is recommend to use a Raspberry Pi 4 Model B with at least 8 GB RAM.*\
*Caution: Nessus only runs on a Raspberry Pi 32 bit OS!*: <https://www.reddit.com/r/nessus/comments/1d62q5n/nessus_package_installation_error_raspberry_pi_5/>

1. Download the package file for the current version (`.deb`).
2. Install the package via `dpkg -i Nessus-10.0.0-raspberrypios_armhf.deb`.
3. Start the Nessus daemon with `/bin/systemctl start nessusd.service`.
4. Open Tenable in the browser with `https://<IP address>:8834`. Use *localhost* if the installation is done locally.
5. Perform the remaining Nessus installation steps in the browser.

## Usage

Tenable can be used for scanning up to 16 host devices. Discovery scans however support more than 16 IPs.[^0D53a00007ZjncaCAB]

The free version of Tenable does not support agent scanning, credentialed scanning is the only way when carrying out deep system analyses. Agents scans are part of the Nessus Manager paid version where the collected data can be send to e.g. [Tenable.sc](https://www.tenable.com/products/tenable-sc). On-site scans with local admin privileges will be able to analyse the system better than unprivileged scans or endpoint analysis. Endpoint scans which scan the host for open ports do have their own use though, which is to say that they can be used to detect unused services or critical connections to the network.

In this context, it is best to use static IPs for the host devices that should be scanned. Or, if possible, directly use the results from a discovery scan to execute a vulnerability scan for the discovered devices.

## Running a credentialed scan

The scan should be done via a dedicated account used for scanning that has appropriate permissions (local administrator group). Otherwise, scan results may be incomplete.[^admin-privileges][^access-level]

User accounts and admin accounts of users should not be used for scanning (isolation concept).

To store passwords for these dedicated accounts, Bitwarden might be useful to have on the server running Tenable.

### Considerations to take into account

- Log **monitoring** for when the account is in use outside of standard change control hours, with alerts for activities outside of normal windows.
- Perform frequent **password rotation** for privileged accounts more often than the "normal" internal standard.
- Enable accounts only when the time window for scans is active; **disable accounts** at other times.[^disable-account]
- On non-Windows systems, do not allow remote root logins. Configure your scans to **utilize escalation** such as su or sudo.
- (Use **key authentication** instead of password authentication.)

### Protecting credentials

#### Windows

There are a few best practices outlined [here](https://www.tenable.com/blog/5-ways-to-protect-scanning-credentials-for-windows-hosts) for an AD environment, however, this article only concerns computers that are not part of a domain.

For authentication methods on Windows suitable for Nessus, see [Scans > Scan Templates > Credentials > Host Credentials > Windows](https://docs.tenable.com/nessus/Content/Windows.htm).

#### Linux

General tips for protecting credentials are outlined [here](https://www.tenable.com/blog/5-ways-to-protect-scanning-credentials-for-linux-macos-and-unix-hosts):

1. **Securely configure SSH:** Tips for SSH can be read [here](./../../ssh.md).
2. **Least privilege functionality:** Allow access to what is needed ([Configuring Least Privilege SSH scans with Nessus](https://www.tenable.com/blog/configuring-least-privilege-ssh-scans-with-nessus) may be of help).
3. **Unique accounts for authentication and assessments:** Consider setting [this in Nessus](https://docs.tenable.com/nessus/Content/SSH.htm).
4. **SSH key encryption:** If using a SSH key, a passphrase should be added so that the key file is encrypted.

For authenticating on Linux, see [Scans > Scan Templates > Credentials > Host Credentials > SSH](https://docs.tenable.com/nessus/Content/SSH.htm).

### Common Scan Failure Indicators

The scan may contain `Info` segments that contain indicators whether the scan executed successfully:

1. **WMI Not Available:** Indicates that WMI is either not enabled as a service on the target, or WMI-In is not enabled on the software firewall (see the sections Remote Registry, WMI and Firewall for more details).
2. **Nessus Scan Information (Plugin 19506)** contains the text `Credentialed checks: No`.
3. **Authentication Failure - Local Checks Not Run:** This often appears if the Remote Registry is not activated.
4. **Nessus Windows Scan Not Performed with Admin Privileges:** Most likely indicates that the administrative shares are not enabled or that the provided credentials do not belong to an admin account.

On the contrary, `WMI Available` and `Credentials checks: Yes` are a sign of a successful scan.

## Readiness check

### Scanning Windows

To enable a credentialed scan on **Windows**, the host device needs to be configured with certain settings.[^windows-settings][^admin-account]

The script in this project which applies this configuration automatically should **only be used for computers that are not part of any domain**.

To run the script, open PowerShell as admin, enter `powershell -ExecutionPolicy RemoteSigned` and run `scan_preparation_win.ps1`.

After the scan has completed successfully, `revert_scan_win.ps1` should be used to revert all changes.

Inspirations for these checks have been taken from [Nessus-Powershell-Oneliners](https://github.com/kAh00t/Nessus-Powershell-Oneliners/blob/main/NessusOneLiners.md) and [Nessus Credentialed Assessment Readiness Check (Windows)](https://github.com/tecnobabble/nessus_win_cred_test).

The following section details the required settings for a successful scan.

*Notice: Some checks require language-specific queries.*

#### User account control (UAC)

Disable User Account Control (UAC) by setting it to `Never Notify`.[^uac]

Furthermore, add the registry key `LocalAccountTokenFilterPolicy` in `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` and set its value to 1.

In Windows 7 and 8, if you disable UAC, then you must set `EnableLUA` to 0 as well.

#### Remote registry

In the `Services` dialogue (*services.msc*), remote registry must be activated (set to `Automatic`) so that Nessus can scan the system for insecure registry configurations.[^remote-registry]

#### Windows Management Instrumentation (WMI)

Like the remote registry, WMI must be active while scanning.

#### File and printer sharing

File and printer sharing needs to be activated for the scan.[^printer-sharing]

```ps
Set-NetFirewallRule -DisplayGroup "File and printer sharing" -Enabled True -Profile Private
```

Setting file and printer sharing does **not** have any effect on the following settings:

```ps
Get-SmbShare
Get-Service LanMan*
Get-NetAdapterBinding -DisplayName "File and printer sharing for Microsoft networks"

# See admin remote file shares
Get-SmbServerConfiguration | Select AutoShareServer,AutoShareWorkstation
```

#### Enable admin remote file shares (client and server)

*Notice: Restart required for changes to take effect.*

Nessus needs access to remote file shares like C$ and ADMIN$. By default, these are activated and should stay enabled.

Set AutoShareServer and AutoShareWks in `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanServer\Parameters` to 1 or remove them.

```ps
Get-SmbServerConfiguration | Select-Object AutoShareServer,AutoShareWorkstation

# Enable
Set-SmbServerConfiguration -AutoShareServer $True -AutoShareWorkstation $True -Confirm:$false

# Disable
Set-SmbServerConfiguration -AutoShareServer $False -AutoShareWorkstation $False -Confirm:$false
```

### Scanning Linux

**Linux** does support credentialed scans via SSH key authentication.[^linux-scan] The account used for scanning must have root privileges.

*Notice: If the shell variable PS1 is shorter than 4 letters, the scan time may drastically increase.*[^ps1]

#### Generate SSH public and private key pair

It does not matter where and how the key pair is created. However, it is important that the defined Tenable Nessus user owns the keys.

Create a key pair with `ssh-keygen -t ed25519`. It is recommended to set **nessus** as the filename. Then, choose a passphrase (or choose an empty password by pressing `Return` twice). If you specify a passphrase, you must specify it in **Policies** > **Credentials** > **SSH settings** for Tenable Nessus to use key-based authentication.

The private key will **stay on the server running Nessus**. The public key will be distributed to all clients that are scanned.

To add a user for Nessus to login with, use the `adduser <username>` command. A prompt asking for the password and some optional information will appear. It does not matter what is entered in the prompt.

Then, add the user to the `sudo` group with `usermod -aG sudo <username>`. Commands issued with sudo by this user will now run with root privileges.[^sudo-user]

You must create the directory under the new account’s home directory to hold the public key. By default, the key file is copied under `/home/<username>/.ssh` and added to the `authorized_keys` file.

```sh
chown -R <username>:<username> /home/<username>/.ssh/
chmod 700 /home/<username>/.ssh
chmod 600 /home/<username>/.ssh/authorized_keys
```

Tenable Nessus encrypts all passwords stored in policies. However, Tenable recommends using SSH keys for authentication rather than SSH passwords. This helps ensure that someone does not use the same username and password you are using to audit your known SSH servers to attempt a login into a system that may not be under your control.

When no scan is running, the user account can be disabled to forbid any login (even SSH) by `sudo usermod --expiredate 1 <username>`. Reenable the account with `sudo usermod --expiredate "" <username>`.[^disable-account-linux]

To verify that the login over SSH works, use the `id` command:

```sh
ssh -i <ssh_private_key> nessus-scan@<scanned_host> id
```

#### Activate SSH server on scanned host

The host that should be scanned by Nessus requires a SSH server, so Nessus can login to the system.[^SSH-server]

```sh
sudo apt install openssh-server
sudo systemctl start ssh
```

#### Global Credential Settings

| Option | Default Value | Description |
| :-: | :-: | :-- |
| **known_hosts file** | none | If an SSH **known_hosts file** is available and provided as part of the Global Credential Settings of the scan policy in the **known_hosts file** field, Tenable Nessus attempts to log into hosts in this file. This can ensure that someone does not use the same username and password you are using to audit your known SSH servers to attempt a log into a system that may not be under your control. |
| **Preferred port** | 22 | You can set this option to direct Tenable Nessus to connect to SSH if it is running on a port other than 22. |
| **Client version** | OpenSSH_5.0 | Specifies which type of SSH client Tenable Nessus impersonates while scanning. |
| **Attempt least privilege** | Cleared | Enables or disables dynamic privilege escalation. When enabled, Tenable Nessus attempts to run the scan with an account with lesser privileges, even if you enable the `Elevate privileges with` option. If a command fails, Tenable Nessus escalates privileges. Plugins 102095 and 102094 report which plugins ran with or without escalated privileges.<br><br>*Note: Enabling this option may increase scan run time by up to 30%.* |

## Managing Nessus

The service behind Nessus Essentials is called `nessusd` and its status can be retrieved via `service nessusd status`.

There is also the `/opt/nessus/sbin/nessuscli` tool to e.g. reset the password of the web interface.

### License activation

When not using Nessus for a long time or when the license expires, it may be that Nessus is not able to download the newest core update and the current plugin set. Upon trying to [update](#installing-updates) Nessus via the terminal, the following message will appear:

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
[^admin-privileges]: For more details, see [Credentialed Scanning and Privileged Account Use](https://docs.tenable.com/nessus/compliance-checks-reference/Content/CredentialedScanningandPrivilegedAccountUse.htm).
[^access-level]: See [Tenable Nessus Credentialed Checks § Access Level](https://docs.tenable.com/nessus/Content/NessusCredentialedChecks.htm#Access-Level).
[^disable-account]: `net user <username> /active:no`. Activate again using the option *yes*.
[^windows-settings]: See [Credentialed Checks on Windows](https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm).
[^admin-account]: See [Scanning with non-default Windows Administrator Account](https://community.tenable.com/s/article/Scanning-with-non-default-Windows-Administrator-Account?language=en_US).
[^uac]: In German, the dialogue is called "Einstellungen der Benutzerkontensteuerung ändern" and needs to be set from `Standard` to `Nie benachrichtigen`.
[^remote-registry]: In German, `Remoteregistrierung` must be set from `Deaktiviert` to `Automatisch`.
[^printer-sharing]: In German, `File and printer sharing` is called `Datei- und Druckerfreigabe`.
[^linux-scan]: See [Credentialed Checks on Linux](https://docs.tenable.com/nessus/Content/CredentialedChecksOnLinux.htm) and [SSH](https://docs.tenable.com/nessus/Content/SSH.htm).
[^ps1]: The shell variable PS1 (not to be confused with environment variable) defines the prompt text in the console displayed to the left, before typing in a command. It's default value is described in `.bashrc` with `PS1='\u@\h:~\$ '`. For more information, see [Prompt](https://wiki.ubuntuusers.de/Bash/Prompt/).
[^sudo-user]: See [How To Create A New Sudo Enabled User on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-sudo-enabled-user-on-ubuntu) and [How To Edit the Sudoers File](https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file)
[^disable-account-linux]: [How to enable or disable a user?](https://askubuntu.com/a/607108)
[^SSH-server]: See more details [here](https://www.veuhoff.net/ubuntu-ssh-server-installation-und-konfiguration-aktivierung/).

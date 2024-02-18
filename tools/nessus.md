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

The free version of Tenable does not support agent scanning, credentialed scanning is the only way when carrying out deep system analyses. Agents scans are part of the Nessus Manager paid version where the collected data can be send to e.g. [Tenable.sc](https://www.tenable.com/products/tenable-sc). On-site scans with local admin privileges will be able to analyse the system better than a unprivileged scans or endpoint analysis. Endpoint scans which scan the host for open ports do have their own use though, which is to say that they can be used to detect unused services or critical connections to the network.

In this context, it is best to use static IPs for the host devices that should be scanned. Or, if possible, directly use the results from a discovery scan to execute a vulnerability scan for the discovered devices<!--TODO: Investigate if it is possible to reuse the scan results in such a way.-->.

## Running a credentialed scan

The scan should be done via a dedicated account used for scanning that has appropriate permissions. User accounts and admin accounts of users should not be used.

To store passwords for these dedicated accounts, Bitwarden might be useful to have on the server running Tenable.

### Configuration

#### Windows

To enable a credentialed scan on **Windows**, the host device needs to be configured:

- Activate remote registry, so Tenable can remotely access the registry settings.
- Turn on file and printer sharing.
- Set the user account control (UAC) setting to `Never notify`.
- Add the registry key `LocalAccountTokenFilterPolicy` in *HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Window\CurrentVersion\Policies\System* and set its value to 1.

TODO: check which of these options may decrease the device's security (e.g. the UAC thing is dangerous but can't be changed because the pc is not in a domain)

#### Linux

**Linux** does support credentialed scans via SSH key authentication.

### Sources

- https://docs.tenable.com/nessus/Content/NessusCredentialedChecks.htm
- https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm
- https://docs.tenable.com/nessus/compliance-checks-reference/Content/CredentialedScanningandPrivilegedAccountUse.htm
- https://community.tenable.com/s/question/0D53a00006seVRHCA2/credentialed-scans-of-windows-10-workgroup-machines-with-nessus-essentials
- https://community.tenable.com/s/article/Scanning-with-non-default-Windows-Administrator-Account
- https://www.tenable.com/blog/4-best-practices-for-credentialed-scanning-with-nessus
- https://www.anthonyram.com/blog/a-guide-to-installing-and-using-the-nessus-vulnerability-scanner
- https://security.berkeley.edu/faq/nessus-network-vulnerability-scanning/how-do-i-run-credentialed-nessus-scan-windows-computer

### Protecting credentials

- https://www.tenable.com/blog/5-ways-to-protect-scanning-credentials-for-windows-hosts
- https://www.tenable.com/blog/how-to-protect-scanning-credentials-overview

## Managing Nessus

The service behind Nessus Essentials is called `nessusd` and its status can be retrieved via `service nessusd status`.

There is also the `/opt/nessus/sbin/nessuscli` tool to e.g. reset the password of the web interface.

## Annotations

[^0D53a00007ZjncaCAB]: [Steve Gillham-1 in "Looking for clarification on Essentials 16 limit."](https://community.tenable.com/s/question/0D53a00007ZjncaCAB/looking-for-clarification-on-essentials-16-limit)

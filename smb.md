# Server Message Block (SMB)

SMB is a protocol for client-server communication for sharing files, printers and other network ressources. It can also be used for inter-process communication (IPC). Originally, it was developed for Windows, but more and more operation systems are adapting to it. Linux for example uses Samba.

Any computer supporting file sharing has both a SMB *server* for providing access to its files and a SMB *client* for accessing a remote computers' files. In Windows, the services `LanmanServer` and `LanmanWorkstation` respectively are responsible for that task which are running on the ports 445 and 139.[^lanman]

<!--disabling the Lanman services does not impact the ability to use the local printer (if it supports TCP/IP that is) and it also increases security > only deactivate if file and printer sharing is not used-->

There are a handful of default file shares like ADMIN$, C$ and IPC$ meant for administrative purposes.[^dollar] They **should not be deactivated** because complications may arise when accessing network shares.[^deactivate-default-share] Instead, they should be protected with proper firewall rules (local client). `Get-SmbShare` creates a listing of all SMB shares.

Overview over the default shares and their purpose:

| File share name | Description |
| :-: | :-- |
| Admin$ | Remote Admin (refers to %SystemRoot% directory), used for remote computer management |
| IPC$ | Remote IPC, used to communicate with programs via named pipes |
| C$ | Default Share. Shared system drive. If there are any other drives on the computer that have letters assigned to them, these will also be automatically published as admin shares (D$, E$, etc.). |
| Print$ | Published when you share your printer (opens access to the printer drivers directory C:\Windows\system32\spool\drivers) |
| FAX$ | For shared fax server access |

Registry settings for the two services are available under `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services` > `LanmanServer` and `LanmanWorkstation` respectively.

## Security considerations

### Disabling SMB 1.0

SMB 1.x is insecure because it does not support encryption and should be deactivated, however, keep in mind that some legacy systems like printers may only use this protocol.

If `Get-SmbServerConfiguration | Select EnableSMB1Protocol` shows *True*, it means the SMB server still supports SMB Version 1.

`Get-SmbSession | Select ClientComputerName, ClientUserName, NumOpens, Dialect` displays open SMB sessions on the server and which protocol version is used for them. Likewise, `Get-SmbConnection` shows connections initiated by the client.

### Restricting SMB traffic to a trusted network

Activate file and printer sharing on the firewall only for the private profile. **Never enable this for the public profile.**

```ps
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private
```

In the user interface, this can be done under `Windows Defender Firewall` > `Allow an app or feature through Windows Defender Firewall`. Now check the box for `File and Printer Sharing` under Private or Domain only. Do **not** check the box under Public.

### Enabling security features in SMB 3.x

#### SMB encryption

Keep in mind that clients that do not support encryption will not be able to communicate with the server upon turning on this feature.

Furthermore, there may be a notable performance cost when using encryption compared to non-encrypted traffic.

```ps
Set-SmbServerConfiguration -EncryptData $True -Force
```

If encryption should just be enabled for one specific share (e.g. *Projects*), use the following command:

```ps
Set-SmbShare -Name Projects$ -EncryptData $True -Force
```

*Notice: Setting the property `RejectUnencryptedAccess` to "false" allows unencrypted traffic for devices not supporting encryption despite encryption being required for connections (see above). However, this workaround is not recommended and the devices should be updated instead.*

#### SMB signing

SMB message signing allows for verifying the exchanged data's integrity by attaching a hash value.

If server-side SMB signing is required, a client will not be able to establish a session with that server unless it has client-side SMB signing enabled. By default, client-side SMB signing is enabled on workstations, servers, and domain controllers.

Similarly, if client-side SMB signing is required, that client will not be able to establish a session with servers that do not have packet signing enabled. By default, server-side SMB signing is enabled only on domain controllers.[^signing]

```ps
Set-SmbServerConfiguration -RequireSecuritySignature $True -Force
```

There is another property named `EnableSecuritySignature`, which is only used with SMB 1.0. With SMB 2.0 or higher, this setting is ignored and does not have any effect.

## Connecting a printer to a network

There are several ways to connect a printer to a network.

### Wired Connection

#### Ethernet

One of the most common methods is connecting the printer directly to the network using an Ethernet cable. This involves:

1. Connecting an Ethernet cable from the printer's Ethernet port to a router or network switch
2. Configuring the printer with an IP address on the network

Ethernet provides a fast, reliable connection and is suitable for most office environments.

#### USB to Router

For printers without built-in networking capabilities:

1. Connect the printer to a router's USB port using a USB cable
2. The router shares the printer on the network

This method turns a USB printer into a network-accessible device.

### Wireless Connection

#### Wi-Fi

Many modern printers have built-in Wi-Fi capabilities:

- The printer connects directly to the wireless network
- No cables are required
- Allows flexible printer placement

This is convenient for home and small office use.

#### Wi-Fi Direct

Some printers support Wi-Fi Direct:

- Creates a direct wireless connection between the printer and devices
- Does not require a Wi-Fi network infrastructure

### Print Server

For older printers without networking features:

- Connect the printer to a dedicated print server device
- The print server connects to the network and shares the printer

This allows legacy printers to be used on modern networks.

### Printer sharing

Printers can also be hooked up to a network device like a laptop which then shares the printer to all other devices on the network:[^printer-sharing]

- File and printer sharing must be enabled
- Print requests are first send to the management device and then transformed into the required format for the printer

## Sources

- [The SMB protocol: All you need to know](https://4sysops.com/archives/the-smb-protocol-all-you-need-to-know/)
- [SMB security enhancements](https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-security)
- [How to detect, enable and disable SMBv1, SMBv2, and SMBv3 in Windows](https://learn.microsoft.com/en-us/windows-server/storage/file-server/troubleshoot/detect-enable-and-disable-smbv1-v2-v3)
- [Stop using SMB1](https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858)
- [Printer Sharing](https://www.techopedia.com/definition/10273/printer-sharing)

## Annotations

[^lanman]: PowerShell command: `Get-Service Lanman*`
[^dollar]: The dollar sign at the end signifies that these are administrative shares. See [Managing Administrative Shares (Admin$, IPC$, C$) on Windows](https://woshub.com/enable-remote-access-to-admin-shares-in-workgroup/).
[^deactivate-default-share]: See [Security Question: Do you turn off C$ admin shares?](https://community.spiceworks.com/t/security-question-do-you-turn-off-c-admin-shares/319617). Compare with [Credentialed Checks on Windows](https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm) which states that ADMIN$ is deactivated by default on Windows 10.
[^signing]: See - [Require SMB Security Signatures](https://learn.microsoft.com/en-us/previous-versions/orphan-topics/ws.11/cc731957(v=ws.11)?redirectedfrom=MSDN)
[^printer-sharing]: See for example [How to Share Printer on Network (Share Printer in-between Computers) Easy](https://www.youtube.com/watch?v=tg1soEWNcFg).

# Server Message Block (SMB)

SMB is a protocol for client-server communication for sharing files, printers and other network ressources. It can also be used for inter-process communication (IPC). Originally, it was developed for Windows, but more and more operation systems are adapting to it. Linux for example uses Samba.

Any computer supporting file sharing has both a SMB *server* for providing access to its files and a SMB *client* for accessing a remote computers' files. In Windows, the services `LanmanServer` and `LanmanWorkstation` respectively are responsible for that task which are running on the ports 445 and 139.[^lanman]

There are a handful of default file shares like ADMIN$, C$ and IPC$ meant for administrative purposes. They **should not be deactivated** because complications may arise when accessing network shares.[^deactivate-default-share] Instead, they should be protected with proper firewall rules (local client). `Get-SmbShare` creates a listing of all SMB shares.

Registry settings for the two services are available under `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services` > `LanmanServer` and `LanmanWorkstation` respectively.

<!--disabling the Lanman services does not impact the ability to use the local printer (if it supports TCP/IP that is) and it also increases security > only deactivate if file and printer sharing is not used-->

## Security considerations

### Disabling SMB 1.0

SMB 1.x is insecure because it does not support encryption and should be deactivated, however, keep in mind that some legacy systems like printers may only use this protocol.

If `Get-SmbServerConfiguration | select EnableSMB1Protocol` shows *True*, it means the SMB server still supports SMB Version 1.

`Get-SmbSession | select ClientComputerName, ClientUserName, NumOpens, Dialect` displays open SMB sessions on the server and which protocol version is used for them. Likewise, `Get-SmbConnection` shows connections initiated by the client.

### Restricting SMB traffic to a trusted network

Activate file and printer sharing on the firewall only for the private profile. **Never never enable this for the public profile.**

```ps
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Private
```

In the user interface, this can be done under `Windows Defender Firewall` > `Allow an app or feature through Windows Defender Firewall`. Now check the box for `File and Printer Sharing` under Private or Domain only. Do **not** check the box under Public.

### Enabling security features in SMB 3.x

#### SMB encryption

Keep in mind that clients that do not support encryption will not be able to communicate with this server.

Furthermore, there may be performance issues when enabling this feature.

```ps
Set-SmbServerConfiguration –EncryptData $True -Force
```

#### SMB signing

SMB message signing allows for verifying the exchanged data's integrity by attaching a hash value.

If either the client or the server have this setting activated, the messages will be signed.

```ps
Set-SmbServerConfiguration -RequireSecuritySignature $True -Force
```

## Todo

Helpful articles:

- [The SMB protocol: All you need to know](https://4sysops.com/archives/the-smb-protocol-all-you-need-to-know/)
- [SMB security enhancements](https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-security)

File and printer sharing:

- <https://networkencyclopedia.com/file-and-printer-sharing-for-microsoft-networks/>
- <https://www.techopedia.com/definition/10273/printer-sharing>

Administrative shares:

- [Managing Administrative Shares (Admin$, IPC$, C$) on Windows](https://woshub.com/enable-remote-access-to-admin-shares-in-workgroup/)

Other pages:

- [How (and why) to disable 'File and Printer Sharing' on your Windows PC](https://www.youtube.com/watch?v=Gqdd6w2cue8)
  - If a service is not used, it should be deactivated.<!--What does this feature entail (printing, transmitting files between computers) ?-->
- [How to Share Printer on Network (Share Printer in-between Computers) Easy](https://www.youtube.com/watch?v=tg1soEWNcFg)
- [Require SMB Security Signatures](https://learn.microsoft.com/en-us/previous-versions/orphan-topics/ws.11/cc731957(v=ws.11)?redirectedfrom=MSDN)
- [Stop using SMB1](https://techcommunity.microsoft.com/t5/storage-at-microsoft/stop-using-smb1/ba-p/425858)

## Annotations

[^lanman]: PowerShell command: `Get-Service Lanman*`
[^deactivate-default-share]: See [Security Question: Do you turn off C$ admin shares?](https://community.spiceworks.com/t/security-question-do-you-turn-off-c-admin-shares/319617). Compare with [Credentialed Checks on Windows](https://docs.tenable.com/nessus/Content/CredentialedChecksOnWindows.htm) which states that ADMIN$ is deactivated by default on Windows 10.

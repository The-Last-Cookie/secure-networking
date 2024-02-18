# Using SSH

SSH is a protocol for remote connection to a server. Usually, it is used for remote management (server configuration) or file transfer.

Upon first connection, it will ask if the connection should actually be established. Acknowledging this will add an entry in the file `~/.ssh/known_hosts` to make sure the user only connects to trustable servers.

Using key-based authentication instead of passwords does not increase security. However, it makes the usage more convenient because the user does not need to type in a password.

## Generating a key pair

1. **Basic command specifying the algorithm:** `ssh-keygen -t ed25519 -C "your@email.com"`
2. **Type in the filename.** It is recommended to use the service's name the key will be used for. Create a single key pair for every server/service.
3. **Choose a passphrase.**

The keypair can now be found under the HOME directory in `~/.ssh/KEYNAME`.

### Configuring the SSH service on the server

**Upload the public key to the server/service.** The public key file (.pub) is distributed publicly. GitHub for example has a [WebUI for that](https://github.com/settings/keys).

If done manually, the public key must be added to the file `~/.ssh/authorized_keys`.

It is important that the files used in the context of SSH have the right permissions. As a default value, these commands can be typed in:

```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## SSH hardening

Not everything that is blindly recommended, actually helps in securing a SSH connection. Most of the tips that can be found on the web will only obscure entries and keep script kiddies away. For example, moving the SSH listening port from the standard setting `22` to an unknown port like `1337` will prevent bots from entering that only search for SSH on the standard port.

For more information, take a look at [Secure Secure Shell](https://blog.stribik.technology/2015/01/04/secure-secure-shell.html), [How To Protect Your Linux Server From Hackers!](https://www.youtube.com/watch?v=fKuqYQdqRIs), and [the official documentation](https://www.man7.org/linux/man-pages/man5/sshd_config.5.html).

### Insecure algorithms

The ssh configuration can be checked with `ssh-audit`.

The repository to the project is available [here](https://github.com/jtesta/ssh-audit). It can be installed as a pip package with `python3 -m pip install ssh-audit`.

`ssh-audit localhost` then identifies insecure algorithms that are enabled in the config.

These insecure ciphers need to be disabled in the ssh config, like so:

```sh
KexAlgorithms -diffie-hellman-group14-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521

Ciphers -chacha20-poly1305@openssh.com

Macs -hmac-sha1,hmac-sha1-etm@openssh.com,hmac-sha2-256,hmac-sha2-512,umac-128@openssh.com,umac-64-etm@openssh.com,umac-64@openssh.com

HostKeyAlgorithms -ecdsa-sha2-nistp256
```

**Notice:** Sometimes upon connection with the server, the client is not able to find an allowed MAC on its own. Then the user needs to specify the MAC (e.g. `hmac-sha2-512-etm@openssh.com`) with a parameter:

```sh
ssh -m <mac> <user>@<address>
```

### User management

*Warning: Be careful when applying this, as this can lead to locking out oneself from the server!*

SSH connections should only be done via expected users. Create a group for SSH and add the users to that group. Then, this group can be added to the SSH `AllowGroups` setting.

```sh
sudo groupadd ssh-user
sudo usermod -a -G ssh-user <username>
```

```sh
AllowGroups ssh-user
```

This is not done out of security reasons, but can be useful when having several people that need to access the same server via SSH.

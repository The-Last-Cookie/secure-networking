# pihole

Tutorials:

- [RPiList/specials](https://github.com/RPiList/specials)
  - [Anleitungen](https://github.com/RPiList/specials/tree/master/Anleitungen)
  - [Benötigte Hardware](https://github.com/RPiList/specials/blob/master/Ben%C3%B6tigte%20Hardware.md)
- [DAS halbiert eure Ladezeiten | Pi-Hole-Tutorial](https://youtu.be/FjNkv2aPiiA)
- [Pi-hole: Einrichtung und Konfiguration mit Fritz!Box](https://www.kuketz-blog.de/pi-hole-einrichtung-und-konfiguration-mit-fritzbox-adblocker-teil1/)

## Installation

Pihole can be installed with `sudo curl -sSL https://install.pi-hole.net | bash`.

While installing, note down the web interface password that is shown in the terminal to later access the web interface for the first time.

Now add the Raspberry Pi's IP address as a DNS to your router's settings.[^router-settings]

The web interface is now accessible via `http://<IP address>/admin`. The standard port of the web interface is 80.

## Serving the pihole service over SSL

<!--TODO: Move to ssl.md?-->

When installing SSL on a web server, it is crucial to understand what web server is used and what the configuration looks like. Examples for web servers are `Nginx` and `Apache`. In the case of pihole v5, it's `lighttpd`.

**Step 1:** Use OpenSSL to create the pem file.

```sh
openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -noenc
```

This pem file now contains a key and a certificate (.crt) file.

Following the above, the `.pem` file needs to be moved to `/etc/lighttpd/ssl/`. The location doesn't really matter here as long as access is given to the files needed (*sudo chown www-data [pem file]*). "SSL" or "TLS" as the folder name is the most common setup.

**Step 2:** Add the SSL config in the `/etc/lighttpd/conf-available/10-ssl.conf` file, where "10" notes down the order in which the config files are loaded in (which number is used is not important here).

```php
# https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_SSL
# https://doc.lighttpd.net/lighttpd2/mod_openssl.html

server.modules += ("mod_openssl")

$HTTP["host"] =~ "(<IP address>|^pi.hole$)" {

  # Enable the SSL engine with a LE cert, only for this specific host
  $SERVER["socket"] == ":443" {
    ssl.engine = "enable"
    ssl.pemfile = "/etc/lighttpd/ssl/pihole.pem"
    ssl.openssl.ssl-conf-cmd = ("MinProtocol" => "TLSv1.3", "Options" => "-ServerPreference")
  }

  # Redirect HTTP to HTTPS
  $HTTP["scheme"] == "http" {
    $HTTP["host"] =~ ".*" {
      url.redirect = (".*" => "https://%0$0")
    }
  }
}
```

**Step 3:** Enable the newly added module via `lighty-enable-mod`.

```sh
sudo lighty-enable-mod ssl
```

This will create a symlink to the config file in `/etc/lighttpd/conf-enabled/`.

*Note: `lighty-disable-mod` can disable mods.*

**Step 4:** Force-reload the lighttpd server

```sh
sudo service lighttpd force-reload
```

### Notes

Opening the service in the browser now already works and the site can be accessed, however, the browser will warn the user because the certificate is self-signed.

This does not add anything to security because IF an attacker can read the password from the unencrypted connection via MITM, there is a far greater problem. For this attack to work, the hacker needs to already have access to the network.

Nevertheless may it be good for practice to see how certificates work and how they are enabled in a webserver.

## Creating a blocklist

### Consider your "threat" landscape

Randomly shuffling together blocklists may lead to redundancy which reduces overall performance. Aggressively blocking websites can also cause overblocking which breaks websites or renders them unusable. Thus, two goals should be defined:

1. What should be blocked?
2. For what reason/why should it be blocked?

A few examples that demonstrate different blocking contexts:

- blocking excessive device telemetry because constant requests are slowing down the network
- blocking malware and adult-content related domains network wide (irrespective of device) due to protection of minors
- blocking intrusive ads across your entire home network to prevent targeted and privacy invading ads as well as malvertising

### Consider the devices on the network

Note that some blocking rules may only apply to one device. Having a specific device that does finely detailed things should not warrant the blocking rules to be applied globally. Be aware of the data connections between the devices in the network.

### Maintaining blocklists

Blocklists often require frequent updates, so check them regularly or implement a method to automatically use the latest one if using a publicly distributed one.

Here are some predefined blocklists:

- [The Firebog](https://firebog.net/)
- [Blocklist Project](https://github.com/blocklistproject/Lists)
- [RPiList](https://github.com/RPiList/specials/tree/master/Blocklisten)

## Managing blocklists

Blocklists can be added via the `Adlists` tab.

To activate newly added blocklists or reload/update existing blocklists, it is necessary to update the domain database by selecting `Tools` > `Update Gravity` > `Update`.

If the window shows the text

```txt
DNS resolution is currently unavailable
```

then it may help to adjust the nameserver value in the `/etc/resolv.conf` file. When the Pi's IP changes, this might still contain the old IP.[^ping]

On GitHub, there is the [pihole adlist tool](https://github.com/yubiuser/pihole_adlist_tool) available which helps in deciding which adlists to use based on the browser behaviour. For example, it calculates the number of unique domains contained in the ad lists. As always, be careful with unknown scripts.

## Using pihole as DNS

*TODO: this section.*

pihole has the ability to define domains to link to devices in the local network.

There is also unbound, enabling recursive dns lookup.

- [Using unbound as a local recursive dns](https://docs.pi-hole.net/guides/dns/unbound/) (especially round robin lookup)
- [Pi-hole: Einrichtung und Konfiguration mit unbound](https://www.kuketz-blog.de/pi-hole-einrichtung-und-konfiguration-mit-unbound-adblocker-teil2/)

## General maintenance

| Command | Description |
| :-: | :-- |
| pihole -up | Update pihole |
| pihole setpassword | Set password for the web interface |

### Reduce memory access

To minimise load on the SD card, pihole can be configured to not save as often to disk. In `/etc/pihole/pihole.toml`, type in the following settings:

```sh
# How long should queries be stored in the database [days]? | Default: 91
maxDBdays = 14
# How often do we store queries in FTL's database [seconds]? | Default: 60
DBinterval = 300
# How long should IP addresses be kept in the network_addresses table [days]? | Default: 91
expire = 14
```

## Annotations

[^router-settings]: An example setting for the Fritz!Box router has been added [here](/../router.md).
[^ping]: This can also be identified by using `ping`. If the IP is wrong, the command will say `Temporary failure in name resolution`.

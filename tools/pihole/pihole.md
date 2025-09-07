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

When installing SSL on a web server, it is crucial to understand what web server is used and what the configuration looks like. Examples for web servers are `Nginx` and `Apache`. In the case of pihole v6, it's `civetweb`.[^web-v5]

How to setup SSL in general is described in [SSL](../../ssl.md).

SSL is the de facto standard today and is not difficult to implement. Absolute security can not be guaranteed, especially when there are vulnerable IoT devices in the network that could be hacked. So, SSL support should definitely be added whenever possible.

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
[^web-v5]: Prior to Pi-hole v6, it was lighttpd.
[^ping]: This can also be identified by using `ping`. If the IP is wrong, the command will say `Temporary failure in name resolution`.

# Router setup

There are multiple ways to setup DNS in a network. This here is only a suggestion.

## Configuring the local DNS server

The most easy setup is to distribute the DNS information to clients via the DHCP. All clients will receive this information upon updating their DHCP lease. DNS requests will then take the following way:

```txt
Client -> Pi-hole -> Upstream DNS Server
```

The upstream DNS server can either be a public DNS or the router.

Like Fritz!Box, many routers offer a built-in DHCP server. To use this setup, enter the Pi's IP address in the router config under `Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Heimnetz`.

![DHCP settings](img/fritzbox-dhcp.png "Setting in the router")

*Caution: Be careful to not create a DNS loop when determining what the upstream server of what DNS server is (router to Pi-hole and vice-versa).*

Now, add public DNS servers to the router's settings under `Internet/Zugangsdaten/DNS-Server`.

## Using DNS over TLS (DoT)

*Note: This technology is rather unstable. It may cause complete DNS outage if encryption is enforced and there is no fallback to unencrypted DNS traffic.*

DNS requests from the local network should be encrypted via TLS before being sent to an upstream DNS server. This can be configured in the router under `Internet/Zugangsart/DNS-Server`. Here are some as an example:

DNSv4-Server:

- Andere DNSv4-Server verwenden: Check
  - Bevorzugter DNSv4-Server: 94.140.14.140
  - Alternativer DNSv4-Server: 176.9.93.198

DNS over TLS (DoT):

- Verschlüsselte Namensauflösung im Internet (DNS over TLS): Check
  - Zertifikatsprüfung für verschlüsselte Namensauflösung im Internet erzwingen: Check

Auflösungsnamen der DNS-Server:

- unfiltered.adguard-dns.com
- dnsforge.de

## Conditional forwarding

In Pi-hole, only the Fritz!Box should be added as an upstream server. Uncheck every other upstream server in the web interface. Under `Use Conditional Forwarding` type in the following values, separated with commas:

- Enabled as a boolean value
- Local network in CIDR notation: 192.168.50.0/24 (adjust to the network)
- IP address of your DHCP server (router): 192.168.50.1 (IPv4 address of the Fritz!Box)
- Local domain name (optional): fritz.box

The router is now defined as the upstream server of Pi-hole, while the public dns servers are the upstream servers of the router.

So, the final path DNS requests take, looks like this:

```txt
Client -> Pi-hole -> Router -> Public DNS Server
```

By not using Conditional Forwarding and defining public upstream servers directly in Pi-hole, devices will only appear as IP addresses and also won't be resolvable by their hostname.[^kuketz]

## Allowing access only via Pi-hole

TODO

## Sources

- https://docs.pi-hole.net/routers/fritzbox-de
- https://discourse.pi-hole.net/t/pi-hole-und-fritzbox-setup-anleitung/7313/214
- https://forum-raspberrypi.de/forum/thread/51020-fritzbox-und-pihole-korrekt-konfigurieren-damit-alle-geraete-funktionieren/
- https://www.kuketz-blog.de/pi-hole-einrichtung-und-konfiguration-mit-fritzbox-adblocker-teil1/
  - there are also other tips in there, like deactivating bluetooth to save energy

[^kuketz]: More information on this [here](https://www.kuketz-blog.de/pi-hole-einrichtung-und-konfiguration-mit-fritzbox-adblocker-teil1/).

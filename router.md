# Router setup

## Configuring the local DNS server

The most easy setup is to distribute the DNS information to clients via the DHCP. All clients will receive this information upon updating their DHCP lease. DNS requests will then take the following way:

```txt
Client -> Pi-hole -> Upstream DNS Server
```

<!--TODO: Is upstream server here the server configured in pihole or the server configured in the router?-->

Like Fritz!Box, many routers offer a built-in DHCP server. To use this setup, enter the Pi's IP address in the router config under `Heimnetz/Netzwerk/Netzwerkeinstellungen/IP-Adressen/IPv4-Konfiguration/Heimnetz`.

![DHCP settings](tools/img/fritzbox-dhcp.png "Setting in the router")

*Be careful to not create a DNS loop when determining what the upstream server of what DNS server is (router to Pi-hole and vice-versa).*

## Allowing access only via Pi-hole

TODO

## Sources

- https://docs.pi-hole.net/routers/fritzbox-de
- https://discourse.pi-hole.net/t/pi-hole-und-fritzbox-setup-anleitung/7313/214
- https://forum-raspberrypi.de/forum/thread/51020-fritzbox-und-pihole-korrekt-konfigurieren-damit-alle-geraete-funktionieren/
- https://www.kuketz-blog.de/pi-hole-einrichtung-und-konfiguration-mit-fritzbox-adblocker-teil1/
  - there are also other tips in there, like deactivating bluetooth to save energy

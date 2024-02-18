# Secure home network

## General advice

- Keep your software/firmware up-to-date!
- Deactivate/deinstall any service on a device that is not needed! (e.g. Remote Access, UPnP, and WPS)

### Router settings

- **SSID:** Make your SSID (the name of your WiFi) look boring. Default values may disclose information about the router model. SSIDs contaning names or jokes may draw unnecessary attention to your network.
- **Firewall:** Configure/install the router's or the server firewall (if applicable).
- **MAC address filtering:** Use MAC address filtering to keep unwanted devices off your network.
- **Deactivate WPS:** WiFi Protected Setup (WPS) is used to connect devices to a network without typing in the SSID and a password. Instead, there is a button on the router to automatically add a device to the network. However, this technology is deemed insecure and should be deactivated.
- **Deactivate WiFi at night:** At night, when everyone's sleeping anyway, the WiFi can probably be turned off. Again, deactivate everything that is not needed frequently.
- [WiFi Optout](https://www.kuketz-blog.de/empfehlungsecke/#wifi-optout)

### Connections to other devices or interfaces

- **Secure passwords:** Passwords must be long enough and have enough different characters like numbers and special characters. Make sure to change default passwords!
- **SSH key:** A password can theoretically be attacked by a brute force attack. A dedicated SSH key when using SSH is more secure than a password.
- **External connection:** If a service needs to be accessed from an external network, a VPN should be used to connect to the home network. Port forwarding is possible too but presents a security risk because the port is publicly exposed.
- **Web interfaces:** Use HTTPS for web interfaces where possible

## Creating a content provider device

In normal operation, a raspberry pi becomes 60 to 80 °C warm. Usually, the processor throttles itself if it becomes too hot.

raspberry pi that has pihole and other services/utilities running

Serving several services on the same device, over different domains:

Setting up a [reverse proxy](https://superuser.com/questions/394078/how-can-i-map-a-domain-name-to-an-ip-address-and-port) on the raspberry pi allows for multiple domains to map to different ports on the same physical device. Another possibility would be to configure the web server to serve certain content depending on the port. Otherwise, you can only use different ports and the same domain or use a separate physical device with another IP address to have two dns entries in the dns server.

[How To Protect Your Linux Server From Hackers!](https://www.youtube.com/watch?v=fKuqYQdqRIs)

## Firewall

Using Raspberry Pi as firewall with uncomplicated firewall (`ufw`)? -> This is overkill because the router already has a firewall and does nothing for security. However, this could be used to have a DMZ between router and raspberry where only these two communicate with each other. Internal traffic only connects to the raspberry, never with the router directly.

- [Raspberry Pi als Firewall einrichten – so geht’s](https://www.pcwelt.de/article/1152906/raspberry-pi-als-firewall-einrichten-so-geht-s-netzwerksicherheit.html)
- [Harden my pi running pihole? (install ufw)](https://discourse.pi-hole.net/t/harden-my-pi-running-pihole-install-ufw/5642)
- [Pi-hole and UFW](https://discourse.pi-hole.net/t/pi-hole-and-ufw/64224)
- [Linux Security - UFW Complete Guide (Uncomplicated Firewall)](https://www.youtube.com/watch?v=-CzvPjZ9hp8)

## Endpoint Detection and Response (EDR)

While vulnerability passively increases the device's security, actively scanning for threats might be useful too.<!--IDS/IPS might be a topic here as well-->

## Annotations

- https://www.wired.com/story/secure-your-wi-fi-router
- https://www.kaspersky.com/resource-center/preemptive-safety/how-to-set-up-a-secure-home-network
- https://restoreprivacy.com/secure-home-network
- https://www.virtualizationhowto.com/2021/12/configure-pi-hole-ssl-using-a-self-signed-certificate/
- https://michaelrigart.be/https-enabled-on-pi-hole-web-interface/

# Secure home network

## General advice

- Keep your software/firmware up-to-date!
- Deactivate/deinstall any service on a device that is not needed! (e.g. Remote Access, UPnP, and WPS)

### Router settings

- **SSID:** Make your SSID (the name of your WiFi) look boring. Default values may disclose information about the router model. SSIDs containing names or jokes may draw unnecessary attention to your network.
- **Firewall:** Configure/install the router's or the server firewall (if applicable).
- **MAC address filtering:** Use MAC address filtering to keep unwanted devices off your network.
- **Deactivate WPS:** WiFi Protected Setup (WPS) is used to connect devices to a network without typing in the SSID and a password. Instead, there is a button on the router to automatically add a device to the network. However, this technology is deemed insecure and should be deactivated.
- **Deactivate WiFi at night:** At night, when everyone's sleeping anyway, the WiFi can probably be turned off. Again, deactivate everything that is not needed frequently.
- **WiFi optout:** By adding `_optout_nomap` to the SSID, Microsoft and Google will not add the user to "WLAN maps" which allow for tracking them — even if GPS is deactivated.[^wifi-tracking]

### Connections to other devices or interfaces

- **Secure passwords:** Passwords must be long enough and have enough different characters like numbers and special characters. Make sure to change default passwords!
- **SSH key:** A password can theoretically be attacked by a brute force attack. A dedicated SSH key when using SSH is more secure than a password.
- **External connection:** If an internal service needs to be accessed remotely, a VPN should be used to connect to the home network. Port forwarding is possible too but presents a security risk because the port is publicly exposed.
- **Web interfaces:** Use HTTPS for web interfaces where possible.

### System settings

- Windows: Set user account control setting to highest level to always get notified when something on the computer changes.
- Mobile: Turn off connections like WiFi, Bluetooth or GPS when not in use.

### Network sharing

1. **Enable file and printer sharing.** Go to the `Freigabecenter`.
2. **Allow access to the drive.** In the explorer menu, right-click on the drive that should be shared, then `Zugriff gewähren auf` > `Freigabe` > Tick the checkbox `Diesen Ordner freigeben`.
3. **Set the correct permissions.** `Everyone` (Jeder) can be used for the permissions field.[^permissions] <!--TODO: When accessing the drive remotely, a login prompt then appears.-->
4. **Disable file and printer sharing.** After all files have been transmitted, the connection should be properly closed again.

- <https://www.computerwoche.de/article/2860650/komplette-laufwerke-im-netzwerk-freigeben.html>

## Creating a content provider device

In normal operation, a raspberry pi becomes 35 to 45 °C warm. Usually, the processor throttles itself if it becomes too hot.

raspberry pi that has pihole and other services/utilities running

Serving several services on the same device, over different domains:

Setting up a [reverse proxy](https://superuser.com/questions/394078/how-can-i-map-a-domain-name-to-an-ip-address-and-port) on the raspberry pi allows for multiple domains to map to different ports on the same physical device.

Another possibility would be to configure the web server to serve certain content depending on the domain, implemented via virtual hosts. Several services run on one physical server and they are all accessed from the outside via e.g. port 80, but over different domains. This might be difficult management wise though, as the services (i.e. daemons) would need to be linked to the self-configured web server. The web server then manages those daemons via virtual hosts. Fore more information, see [Different VirtualHosts with the same port](https://stackoverflow.com/questions/6069892/different-virtualhosts-with-the-same-port).

## Firewall

Using Raspberry Pi as firewall with uncomplicated firewall (`ufw`) only makes sense when creating isolated subnets. The router already has a firewall and as long as there is no port forwarding configured, internal services are not accessible from the outside.[^paper] Connections can only be opened from inside the network, never vice-versa (except if you want to access the internal network remotely for example via VPN).

However, this could be used to have a DMZ between router and raspberry where only these two communicate with each other. Internal traffic only connects to the raspberry, never with the router directly. This is dangerous though and should be handled with care.

- [Raspberry Pi als Firewall einrichten - so geht's](https://www.pcwelt.de/article/1152906/raspberry-pi-als-firewall-einrichten-so-geht-s-netzwerksicherheit.html)
- [Harden my pi running pihole? (install ufw)](https://discourse.pi-hole.net/t/harden-my-pi-running-pihole-install-ufw/5642)
- [Pi-hole and UFW](https://discourse.pi-hole.net/t/pi-hole-and-ufw/64224)
- [Linux Security - UFW Complete Guide (Uncomplicated Firewall)](https://www.youtube.com/watch?v=-CzvPjZ9hp8)

## Endpoint Detection and Response (EDR)

While vulnerability management passively increases the device's security, actively scanning for threats might be useful too.

- IDS/IPS might be a topic here as well: [Building my home intrusion detection system (Suricata & ELK on a Pi4)](https://www.reddit.com/r/raspberry_pi/comments/np1a8f/building_my_home_intrusion_detection_system/)
- <https://www.ossec.net/>
- [Easy SIEM lab](https://www.youtube.com/watch?v=2XLzMb9oZBI)

## Annotations

[^wifi-tracking]: See [WiFi Optout](https://www.kuketz-blog.de/empfehlungsecke/#wifi-optout)
[^permissions]: See also [What are the different object names in Windows?](https://superuser.com/questions/1629647/what-are-the-different-object-names-in-windows)
[^paper]: A firewall is not needed to block ports that are not used anyway. See [How To Protect Your Linux Server From Hackers!](https://www.youtube.com/watch?v=fKuqYQdqRIs).

- [How to Secure Your Wi-Fi Router and Protect Your Home Network](https://www.wired.com/story/secure-your-wi-fi-router)
- [How to Set Up a Secure Home Network](https://www.kaspersky.com/resource-center/preemptive-safety/how-to-set-up-a-secure-home-network)
- [How to Secure Your Home Network Against Threats](https://restoreprivacy.com/secure-home-network)
- [Configure Pi-hole SSL using a self-signed certificate](https://www.virtualizationhowto.com/2021/12/configure-pi-hole-ssl-using-a-self-signed-certificate/)
- [HTTPS enabled on Pi-hole web interface](https://michaelrigart.be/https-enabled-on-pi-hole-web-interface/)

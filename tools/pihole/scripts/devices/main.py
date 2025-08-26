import os

import config
import pyhole

PI_MAC=config.get("pi_mac")

cert = config.get('cert_bundle')
password = config.get('password')

pi = pyhole.Pihole("https://pi.hole/api", cert)
pi.authenticate(password)


with open("devices.txt", mode="r") as f:
	current_devices = f.readlines()

# Make sure the file gets properly replaced by the new one
os.remove("devices.txt")

devices = pi.network.get_devices()

for device in devices:
	mac_addr = device['hwaddr']
	if mac_addr not in current_devices:
		if mac_addr == "00:00:00:00:00:00" or mac_addr == PI_MAC:
			continue

		print(f"Alert: {mac_addr} not found in device list.")
		current_devices.append(mac_addr + "\n")

with open("devices.txt", mode="w") as f:
	f.writelines(current_devices)

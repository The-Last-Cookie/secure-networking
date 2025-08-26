import config
import pyhole

cert = config.get('cert_bundle')
password = config.get('password')

pi = pyhole.Pihole("https://pi.hole/api", cert)
pi.authenticate(password)


with open("devices.txt", mode="r") as f:
	current_devices = f.readlines()

devices = pi.network.get_devices()

for device in devices:
	if device['hwaddr'] not in current_devices:
		print(f"Alert: {device['hwaddr']} not found in device list.")
		current_devices.append(device['hwaddr'])

with open("devices.txt", mode="w") as f:
	f.writelines(current_devices)

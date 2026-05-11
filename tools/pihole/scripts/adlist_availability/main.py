import config
import pyhole

import json
from datetime import datetime

cert = config.get('cert_bundle')
password = config.get('password')

ADDRESS_STORE = "store.json"
LOG = "addresses.log"

today = datetime.today().strftime("%Y-%m-%d")

pi = pyhole.Pihole("https://pi.hole/api", cert)
pi.authenticate(password)

store = []
with open(ADDRESS_STORE) as file:
	store = json.loads(file.read())

messages = pi.ftl.get_messages()

unavailable_today = []
for message in messages:
	msg = message["plain"]
	if msg.startswith("List with ID ") and msg.endswith(" was inaccessible during last gravity run"):
		tokens = msg.split(" ")
		address = tokens[4]
		address.removeprefix("(")
		address.removesuffix(")")

		unavailable_today.append(address)
		if address not in store:
			store.append(address)
			with open(LOG, mode='a') as file:
				file.write(f"{today}: '{address}' not available.")

for store_address in store:
	if store_address not in unavailable_today:
		with open(LOG, mode='a') as file:
			file.write(f"{today}: '{store_address}' seems to be available again.")

with open(ADDRESS_STORE, mode='w') as file:
	file.write(json.dumps(store))

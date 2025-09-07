import json

CONFIG_PATH = "config.json"

def get(config_name: str):
	config = None
	with open(CONFIG_PATH) as file:
		content = file.read()
		config = json.loads(content)

	return config[config_name]

def save(config_name: str, value) -> None:
		config = None

		with open(CONFIG_PATH, mode='r') as file:
			content = file.read()
			config = json.loads(content)
			config[config_name] = value

		with open(CONFIG_PATH, mode='w') as file:
			file.write(json.dumps(config))

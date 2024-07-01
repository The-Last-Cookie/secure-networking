# getter and setter: https://www.freecodecamp.org/news/python-property-decorator/ ?
# --> make everything a property that should be readable and writeable
# --> only readable is a method

import smbus2
from ina219 import INA219,DeviceRangeError


def join_bytes(*args) -> int:
	"""
	Converts bytes arranged in big-endian format into their integer value
	"""

	if len(args) > 4:
		raise OverflowError

	value = 0
	for i, arg in enumerate(reversed(args)):
		digit_position = 8 * i
		value = arg << digit_position | value
	return value


class Supply:
	def __init__(self) -> None:
		self.DEVICE_BUS = 1

		self.ina_supply = INA219(0.00725, busnum=self.DEVICE_BUS, address=0x40)
		self.ina_supply.configure()
		
	def voltage(self) -> float:
		return self.ina_supply.voltage()
	
	def current(self) -> float:
		return self.ina_supply.current()
	
	def power(self) -> float:
		return self.ina_supply.power()


class Battery:
	def __init__(self) -> None:
		self.DEVICE_BUS = 1
		
		self.ina_batt = INA219(0.005, busnum=self.DEVICE_BUS, address=0x45)
		self.ina_batt.configure()

	def voltage(self) -> float:
		return self.ina_batt.voltage()

	def status(self) -> dict:
		try:
			return {
				"current": self.ina_batt.current(),
				"power": self.ina_batt.power(),
				"error": "",
				"message": ""
			}
		except DeviceRangeError as e:
			return {
				"current": None,
				"power": None,
				"error": "DeviceRangeError",
				"message": str(e)
			}


class Bus:
	def __init__(self, protect_volt=3700, sample_period=2) -> None:
		self.DEVICE_BUS = 1
		self.DEVICE_ADDR = 0x17 # Address on which the processor (STM32) is available via the bus

		self.PROTECT_VOLT = protect_volt

		self.bus = smbus2.SMBus(self.DEVICE_BUS)

		self.sample_period = sample_period

	def _read_byte(self, byte: int) -> int:
		# read registers from processor
		if 0 <= byte >= 256:
			raise ValueError

		return self.bus.read_byte_data(self.DEVICE_ADDR, byte)

	def _write_byte(self, index: int, byte: int) -> None:
		self.bus.write_byte_data(self.DEVICE_ADDR, index, byte)

	def ups_voltage(self) -> str:
		milliVolt = join_bytes(self._read_byte(2), self._read_byte(1))
		return f"{milliVolt} mV"
	
	def pi_voltage(self) -> str:
		milliVolt = join_bytes(self._read_byte(4), self._read_byte(3))
		return f"{milliVolt} mV"
	
	def charging_status(self) -> str:
		if (join_bytes(self._read_byte(8), self._read_byte(7))) > 4000:
			return "USB Type C"
		elif (join_bytes(self._read_byte(10), self._read_byte(9))) > 4000:
			return "Micro USB"
		else:
			return "Not charging"

	# How often the processor asks the INA for data and writes into its registers
	@property
	def sample_period(self) -> str:
		return self._sample_period

	@sample_period.getter
	def sample_period(self) -> str:
		minutes = join_bytes(self._read_byte(22), self._read_byte(21))
		return f"{minutes} min"

	@sample_period.setter
	def sample_period(self, frequency: int) -> str:
		# TODO:
		self._write_byte(self.DEVICE_ADDR, 22, 1)
		self._write_byte(self.DEVICE_ADDR, 21, 1)
		self._sample_period = frequency

	def operation_mode(self) -> str:
		mode = join_bytes(self._read_byte(23))

		if mode == 1:
			return "Normal operation mode"
		
		return "Power off"
	
	def shutdown_countdown(self) -> str:
		seconds = join_bytes(self._read_byte(24))
		return f"{seconds} sec"
	
	def restart_countdown(self) -> str:
		seconds = join_bytes(self._read_byte(26))
		return f"{seconds} sec"

	def uptime(self):
		time = join_bytes(self._read_byte(39), self._read_byte(38), self._read_byte(37), self._read_byte(36))
		return f"{time} sec"

	def serial_number(self) -> str:
		uid0 = "%08X" % join_bytes(self._read_byte(243), self._read_byte(242), self._read_byte(241), self._read_byte(240))
		uid1 = "%08X" % join_bytes(self._read_byte(247), self._read_byte(246), self._read_byte(245), self._read_byte(244))
		uid2 = "%08X" % join_bytes(self._read_byte(251), self._read_byte(250), self._read_byte(249), self._read_byte(248))
		return uid0 + "-" + uid1 + "-" + uid2

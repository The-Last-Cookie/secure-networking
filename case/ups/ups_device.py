import smbus2
from ina219 import INA219, DeviceRangeError


def join_bytes(*args: int) -> int:
	"""
	Converts bytes arranged in big-endian format (MSB) into their integer value
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
		self._device_bus = 1

		self._ina = INA219(0.00725, busnum=self._device_bus, address=0x40)
		self._ina.configure()

	def voltage(self) -> int:
		"""
		Returns milliVolt
		"""
		return self._ina.voltage()

	def current(self) -> int:
		"""
		Returns milliAmpere
		"""
		return self._ina.current()

	def power(self) -> int:
		"""
		Returns milliWatt
		"""
		return self._ina.power()


class Battery:
	def __init__(self) -> None:
		self._device_bus = 1

		self._ina = INA219(0.005, busnum=self._device_bus, address=0x45)
		self._ina.configure()

	def voltage(self) -> int:
		"""
		Returns milliVolt
		"""
		return self._ina.voltage()

	def status(self) -> dict:
		"""
		Returns units in 1/1000
		"""
		try:
			return {
				"current": self._ina.current(),
				"power": self._ina.power(),
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
	def __init__(self, protection_voltage=3700, sample_period=2, shutdown_countdown=10, restart_countdown=10) -> None:
		self._device_bus = 1
		self._device_addr = 0x17 # Address on which the processor (STM32) is available via the bus

		self._bus = smbus2.SMBus(self._device_bus)

		self.protection_volt = protection_voltage
		self.sample_period = sample_period
		self.shutdown_countdown = shutdown_countdown
		self.automatic_shutdown_protection = True
		self.restart_countdown = restart_countdown

	def _read_byte(self, byte: int) -> int:
		"""
		Read a single byte from a dedicated register on the processor.
		Register addresses range from 1 to 256.

		Return: int
		"""
		if not(1 <= byte <= 256):
			raise ValueError

		return self._bus.read_byte_data(self._device_addr, byte)

	def _write_byte(self, index: int, byte: int) -> None:
		self._bus.write_byte_data(self._device_addr, index, byte)

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

	def battery_temperature(self) -> int:
		"""
		Returns °C
		"""
		return join_bytes(self._read_byte(12), self._read_byte(11))

	@property
	def protection_volt(self) -> int:
		volt = join_bytes(self._read_byte(18), self._read_byte(17))
		self._protection_volt = volt
		return self._protection_volt

	@protection_volt.setter
	def protection_volt(self, volt: int):
		if not(0 <= volt <= 4500):
			raise ValueError

		self._write_byte(17, volt & 0xFF)
		self._write_byte(18, (volt >> 8) & 0xFF)
		self._protection_volt = volt

	def battery_capacity(self) -> int:
		"""
		Returns %
		"""
		return join_bytes(self._read_byte(20), self._read_byte(19))

	# How often the processor asks the INA for data and writes into its registers
	@property
	def sample_period(self) -> int:
		minutes = join_bytes(self._read_byte(22), self._read_byte(21))
		self._sample_period = minutes
		return self._sample_period

	@sample_period.setter
	def sample_period(self, frequency: int) -> str:
		if not(1 <= frequency <= 1440):
			raise ValueError

		# convert to single byte
		self._write_byte(21, frequency & 0xFF)
		self._write_byte(22, (frequency >> 8) & 0xFF)
		self._sample_period = frequency

	def operation_mode(self) -> str:
		mode = self._read_byte(23)

		if mode == 1:
			return "Normal operation mode"

		return "Power off"

	@property
	def shutdown_countdown(self) -> int:
		seconds = self._read_byte(24)
		self._shutdown_countdown = seconds
		return self._shutdown_countdown

	@shutdown_countdown.setter
	def shutdown_countdown(self, countdown):
		if countdown == 0:
			self._write_byte(24, 0)
			self._shutdown_countdown = countdown
			return

		if not(10 <= countdown <= 255):
			raise ValueError

		self._write_byte(24, countdown)
		self._shutdown_countdown = countdown

	@property
	def automatic_shutdown_protection(self) -> bool:
		"""
		When the battery becomes low, the UPS automatically shuts down and turns on as soon as AC is available again.
		"""
		back_to_ac = self._read_byte(25)
		self._back_to_ac = back_to_ac
		return self._back_to_ac

	@automatic_shutdown_protection.setter
	def automatic_shutdown_protection(self, isActive: bool):
		self._back_to_ac = isActive
		self._write_byte(25, isActive)

	@property
	def restart_countdown(self) -> int:
		seconds = self._read_byte(26)
		self._restart_countdown = seconds
		return self._restart_countdown

	@restart_countdown.setter
	def restart_countdown(self, countdown):
		if countdown == 0:
			self._write_byte(26, 0)
			self._restart_countdown = countdown
			return

		if not(10 <= countdown <= 255):
			raise ValueError

		self._write_byte(26, countdown)
		self._restart_countdown = countdown

	def uptime(self) -> int:
		"""
		Returns the duration since the device is on in seconds.
		"""
		return join_bytes(self._read_byte(39), self._read_byte(38), self._read_byte(37), self._read_byte(36))

	def serial_number(self) -> str:
		uid0 = "%08X" % join_bytes(self._read_byte(243), self._read_byte(242), self._read_byte(241), self._read_byte(240))
		uid1 = "%08X" % join_bytes(self._read_byte(247), self._read_byte(246), self._read_byte(245), self._read_byte(244))
		uid2 = "%08X" % join_bytes(self._read_byte(251), self._read_byte(250), self._read_byte(249), self._read_byte(248))
		return uid0 + "-" + uid1 + "-" + uid2

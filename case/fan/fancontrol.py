#!/usr/bin/env python3

# Inspired by: https://github.com/Howchoo/pi-fan-controller/tree/master

import time

from gpiozero import OutputDevice


ON_THRESHOLD = 55  # (degrees Celsius) Fan kicks on at this temperature
OFF_THRESHOLD = 50  # (degrees Celsius) Fan shuts off at this temperature
SLEEP_INTERVAL = 60  # (seconds) How often we check the core temperature
GPIO_PIN = 17  # GPIO pin to control the fan


def temperature():
    """Get the core temperature.

    Read file from /sys to get CPU temp in °C * 1000

    Returns:
        int: The core temperature in millicelsius.
    """
    with open('/sys/class/thermal/thermal_zone0/temp') as f:
        temp_str = f.read()

    try:
        return int(temp_str) / 1000
    except (IndexError, ValueError,) as e:
        raise RuntimeError('Could not parse temperature output.') from e

if __name__ == '__main__':
    if OFF_THRESHOLD >= ON_THRESHOLD:
        raise RuntimeError('OFF_THRESHOLD must be less than ON_THRESHOLD')

    fan = OutputDevice(GPIO_PIN)

    while True:
        temperature = temperature()

        # NOTE: `fan.value` returns 1 for "on" and 0 for "off"
        if temperature > ON_THRESHOLD and not fan.value:
            fan.on()

        elif fan.value and temperature < OFF_THRESHOLD:
            fan.off()

        time.sleep(SLEEP_INTERVAL)

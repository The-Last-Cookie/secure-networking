# Copyright (c) 2017 Adafruit Industries
# Author: Tony DiCola & James DeVito
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import time
import subprocess

from ups_device import Bus, Supply, Battery
from screen import Screen


screen = Screen()

padding = -2
top = padding
bottom = screen.height - padding
x = 0

# Display counter
screenC = 0

bus = Bus()
supply = Supply()
battery = Battery()

while True:
    screen.clear()

    # Shell scripts for system monitoring from here: https://unix.stackexchange.com/questions/119126/command-to-display-memory-usage-disk-usage-and-cpu-load
    cmd = "hostname -I | cut -d\' \' -f1"
    IP = subprocess.check_output(cmd, shell=True, encoding='utf-8')
    cmd = "top -bn1 | grep load | awk '{printf \"CPU: %.2f\", $(NF-2)}'"
    CPU = subprocess.check_output(cmd, shell=True, encoding='utf-8')
    cmd = "free -m | awk 'NR==2{printf \"Mem: %s/%sMB %.2f%%\", $3,$2,$3*100/$2 }'"
    MemUsage = subprocess.check_output(cmd, shell=True, encoding='utf-8')
    cmd = "df -h | awk '$NF==\"/\"{printf \"Disk: %d/%dGB %s\", $3,$2,$5}'"
    Disk = subprocess.check_output(cmd, shell=True, encoding='utf-8')
    cmd = "vcgencmd measure_temp | cut -f 2 -d '='"
    temp = subprocess.check_output(cmd, shell=True, encoding='utf-8')

    piVolts = round(supply.voltage(), 2)
    piCurrent = round (supply.current())

    battVolts = round(battery.voltage(), 2)

    status = battery.status()
    if status['error'] is None:
        battCur = round(status['current'])
        battPow = round(status['power'] / 1000, 1)
    else:
        battCur = 0
        battPow = 0

    bus.open()

    if (screenC <= 15):
        # Pi Stats Display
        screen.text((x, top+2), "IP: " + str(IP))
        screen.text((x, top+18), str(CPU) + "%")
        screen.text((x+80, top+18), str(temp))
        screen.text((x, top+34), str(MemUsage))
        screen.text((x, top+50), str(Disk))

    else:
        # UPS Stats Display
        screen.text((x, top+2), "Pi: " + str(piVolts) + "V  " + str(piCurrent) + "mA")
        screen.text((x, top+18), "Batt: " + str(battVolts) + "V  " + str(bus.battery_remaining()) + "%")
        if (battCur > 0):
            screen.text((x, top+34), "Chrg: " + str(battCur) + "mA " + str(battPow) + "W")
        else:
            screen.text((x, top+34), "Dchrg: " + str(0-battCur) + "mA " + str(battPow) + "W")
        screen.text((x+15, top+50), bus.charging_status())

    bus.close()

    screenC += 1
    if (screenC == 30):
        screenC = 0

    screen.display()
    time.sleep(.1)

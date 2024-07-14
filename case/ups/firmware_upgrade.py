#!/usr/bin/env python3

import os
import time
import json
import smbus2
import requests

# How to enter into OTA mode:
# Method 1) Setting register in terminal: i2cset -y 1 0x17 50 127 b
# Method 2) Remove all power connections and batteries, and then hold the power button, insert the batteries.

DEVICE_BUS = 1
DEVICE_ADDR = 0x18
UPDATE_URL = "https://api.52pi.com/update"

def get_serial_number() -> list:
    # Create file serial.number with the serial number in it
    serial = ""
    with open("serial.number") as file:
        serial = file.read()
        serial = serial.strip("\n", "")
        serial = serial.split("-")

    return serial

def get_download_link(serial: list):
    r = requests.post(UPDATE_URL, data={"UID0": serial[0], "UID1": serial[1], "UID2": serial[2]})

    # You can also specify your version, so you can rollback/forward to the specified version
    # r = requests.post(UPDATE_URL, data={"UID0":UID0, "UID1":UID1, "UID2":UID2, "ver":7})

    r = json.loads(r.text)
    if r['code'] != 0:
        print('Can not get the firmware due to:' + r['reason'])
        exit(r['code'])

    return r

def download_firmware():
    serial = get_serial_number()
    if not(len(serial) == 3):
        print("Serial number is not in the expected format: " + str(serial))
        exit()

    link = get_download_link(serial=serial)

    req = requests.get(link['url'])
    if req.status_code == 404:
        print('version not found!')
        exit(-1)

    with open("/usr/local/bin/ups/firmware.bin", "wb") as f:
        f.write(req.content)

    print("Download firmware successful.")

def install_firmware():
    print("The firmware starts to be upgraded. Please keep the power on.")
    print("Interruption in the middle will cause unrecoverable failure of the UPS!")

    bus = smbus2.SMBus(DEVICE_BUS)

    with open("/usr/local/bin/ups/firmware.bin", "rb") as f:
        while True:
            data = f.read(16)
            for i in range(len(list(data))):
                bus.write_byte_data(0x18, i + 1, data[i])
            bus.write_byte_data(0x18, 50, 250)
            time.sleep(0.1)
            print('.', end='', flush=True)

            if len(list(data)) == 0:
                bus.write_byte_data(0X18, 50, 0)
                print('.', flush=True)
                print('The firmware upgrade is complete, please disconnect all power/batteries and reinsert to use the new firmware.')
                break

    bus.close()

download_firmware()
install_firmware()

os.system("sudo halt")
while True:
    time.sleep(10)

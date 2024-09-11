# upsplus

## Installation

```sh
sudo raspi-config nonint do_i2c 0

sudo apt install i2c-tools

# with activating venv
python3.11 -m pip install smbus2
python3.11 -m pip install pi-ina219
# which pip? this worked as well (not activating venv): /path/to/venv/bin/pip
```

More information: <https://wiki.52pi.com/index.php/EP-0136> (registers and installation instructions for example)

## How to upgrade firmware of UPS

```sh
python3 firmware_upgrade.py
```

When `upgrade` process is finished, it will `shutdown` your Raspberry Pi automatically, and you `need` to disconnect the charger and remove all batteries from UPS and then insert the batteries again, then press the power button to turn on the UPS.

***NOTE: Do not assemble UPS with Raspberry Pi with Batteries in it.***

## Battery List

A list of Batteries used by UPSPlus users community.

| Brand | Model | Volt | mAmp | SAMPLE_TIME | Testing | Time |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| DoublePow | ICR18650 | 3.7 | 2600 | 3 |  | +180days |
| GTL EvreFire | ICR18650 | 3.7 | 9900 | 3 | X |  |
| XTAR | ICR18650 | 3.7 | 2600 | 3 | X |  |

Don't forget to replace PROTECT_VOLT variable value, from Battery Volt value. Example: Battery 3.6V = 3600

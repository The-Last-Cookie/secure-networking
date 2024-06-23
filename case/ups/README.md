# upsplus

## How to upgrade firmware of UPS

Upgrade firmware will be via `OTA` style, `OTA` means `over the air`, it allows you `update` or `upgrade` firmware via internet.

- 1. Make sure Raspberry Pi can access internet.
- 2. Download Repository from `GitHub`.

```bash
cd ~
git clone https://github.com/geeekpi/upsplus.git
cd upsplus/
python3 OTA_firmware_upgrade.py
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

Don't forget replace PROTECT_VOLT variable value, from Battery Volt value. Example: Battery 3.6V = 3600

# raspi-ups-stats

Script to show system and UPS statistics on a Raspberry Pi with [UPS Plus](https://wiki.52pi.com/index.php/UPS_Plus_SKU:_EP-0136?spm=a2g0o.detail.1000023.17.4bfb6b35vkFvoW) board and [128x64 OLED display](https://www.amazon.com/dp/B08LYL7QFQ?psc=1&ref=ppx_pop_dt_b_product_details).

## Installation

### Prerequisites

If you're using Raspbian/Raspberry Pi OS, you'll need to enable I2C using `raspi-config` [or dtoverlay=i2c I think?]. You'll then need to install several dependencies with `sudo apt install i2c-tools python3-rpi.gpio libraspberrypi-bin`.

In a python venv, install the required dependencies:

```sh
python3.11 -m pip install smbus2
python3.11 -m pip install pi-ina219
python3.11 -m pip install pillow
# pip install Adafruit-SSD1306 --> seems to be an old library
```

Next, you'll need to download Adafruit's Python library for the OLED display. `git clone https://github.com/adafruit/Adafruit_Python_SSD1306.git` (the new library is [here](https://github.com/adafruit/Adafruit_CircuitPython_SSD1306)). Then `cd Adafruit_Python_SSD1306.git`, `sudo python3 setup.py install`.

Finally, you'll need to download the font files from https://www.dafont.com/pixel-operator.font. The font file `PixelOperator.ttf` will need to be placed in the same directory as the executable script.

### Download and install

Change to a convenient directory and run `git clone https://github.com/danb35/raspi-ups-stats`.

## Auto start on boot

Create `/opt/stats/`, and copy `PixelOperator.ttf` and `stats.py` there.

Then put the systemd unit file in the correct place: `sudo cp stats.service /etc/systemd/system/`.

Then tell systemd to re-scan the unit files with `sudo systemctl daemon-reload`, and start this unit using `sudo systemctl enable --now stats`.

## Cables

- black - GND (9)
- grey - GPIO 3 I2C SCL (5)
- violette - GPIO 2 I2C SDA (3)
- white - 3.3V Power (1)

## Acknowledgements

Original source: https://www.the-diy-life.com/mini-raspberry-pi-server-with-built-in-ups/
Based on: https://github.com/adafruit/Adafruit_Python_SSD1306/blob/master/examples/stats.py

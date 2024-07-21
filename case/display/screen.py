from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

# https://pypi.org/project/Adafruit-SSD1306/
# https://pypi.org/project/adafruit-circuitpython-ssd1306/
import Adafruit_GPIO.SPI as SPI
import Adafruit_SSD1306

ADAFRUIT_GPIO = 3 # GPIO pin where the screen cable is inserted
DEVICE_BUS = 1


class Screen:
    def __init__(self) -> None:
        self._adafruit = Adafruit_SSD1306.SSD1306_128_64(rst=None, gpio=ADAFRUIT_GPIO, i2c_bus=DEVICE_BUS)
        self._adafruit.begin()
        self._adafruit.clear()
        self._adafruit.display()

        self.width = self._adafruit.width
        self.height = self._adafruit.height
        self.font = ImageFont.truetype('PixelOperator.ttf', 16)

        # Make sure to create image with mode '1' for 1-bit color.
        self._image = Image.new('1', (self.width, self.height)) # stellt den Rahmen (Frame) dar, in dem alles gezeichnet wird
        self._draw = ImageDraw.Draw(self._image)

        self.clear()

    def clear(self):
        self._draw.rectangle((0,0,self.width,self.height), outline=0, fill=0)

    def text(self, position, content):
        self._draw.text(position, content, font=self.font, fill=255)

    def display(self):
        self._adafruit.image(self._image)
        self._adafruit.display()

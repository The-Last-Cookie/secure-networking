# Device maintenance cheat sheet

## Raspberry Pi

Common commands:

| Command | Description |
| :-: | :-- |
| sudo reboot | Reboot the system |
| sudo shutdown --poweroff | Shutdown the system (*systemctl poweroff* does the same but does not provide any scheduling ability) |
| lscpu | Display CPU information |
| lsblk | Display disk information |
| free -m | Show RAM information |

### Disable unneeded interfaces

To minimise used energy, the boot config can be configured in `/boot/firmware/config.txt`, so that unnecessary interfaces are deactivated.[^pihole-boot] Some are listed below:

```sh
# Disable analog audio
dtparam=audio=off

# Disable audio via HDMI
dtoverlay=vc4-kms-v3d,noaudio

# Disable Bluetooth, WiFi and HDMI
dtoverlay=disable-bt
dtoverlay=disable-wifi
hdmi_blanking=1
```

(The system needs to be rebooted after changes have been applied to this file.)

### Upgrading system packages

When packages are held back due to dependency issues, `sudo apt full-upgrade` should be preferred instead of trying to manually installing the package.[^full-upgrade]

### (Temporary) apt key file problem

`apt-key` is deprecated and only meant to delete old keys. Every repository managed by apt now receives its own key.

Thus, they are moved from `/etc/apt/trusted.gpg` to `/etc/apt/trusted.d/key1.gpg`, `/etc/apt/trusted.d/key2.gpg` and so on.

*For newly installed Raspberry Pis*, it is enough to move the key file to the correct location via `mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/bookworm_InRelease.gpg`. The name of the `.gpg` file does not matter here, it is solely important that the file is at its right place.[^apt-key]

## Annotations

[^pihole-boot]: The full documentation regarding this file is available [here](https://www.raspberrypi.com/documentation/computers/config_txt.html).
[^full-upgrade]: [Confused about kernel versions and kept back packages](https://forums.raspberrypi.com/viewtopic.php?t=365267)
[^apt-key]: [Warnung apt keyring beim Update beheben](https://forum-raspberrypi.de/forum/thread/60014-warnung-apt-keyring-beim-update-beheben/)

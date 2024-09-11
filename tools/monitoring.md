# Monitoring system performance

The TIG stack allows for efficient performance monitoring also for smaller devices like the Raspberry Pi.

[Telegraf](https://github.com/influxdata/telegraf) collects system information and data and sends it to an instance of [InfluxDB](https://github.com/influxdata/influxdb) where the information is stored. After that, it is accessed via queries and displayed in [Grafana](https://github.com/grafana/grafana).

The plan for now is to install telegraf on the pi running pi hole and the other two programs on a separate pi (pi-monitor).

*Caution: Check those commands with other install guides!*

## Telegraf

```sh
# influxdata-archive_compat.key GPG fingerprint:
#     9D53 9D90 D332 8DC7 D6C8 D3B9 D8FF 8E1F 7DF8 B07E
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
sudo apt-get update && sudo apt-get install telegraf
```

## InfluxDB

.

## Grafana

<https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/>
<https://grafana.com/grafana/download?edition=enterprise&pg=get&plcmt=selfmanaged-box1-cta1>

```sh
sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_10.4.0_arm64.deb
sudo dpkg -i grafana-enterprise_10.4.0_arm64.deb
```

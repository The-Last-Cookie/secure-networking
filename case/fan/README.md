# Tutorial

1. make `fan` folder in /usr/local/bin
2. sudo chown +R /usr/local/bin/fan
3. sudo chmod u+x fancontrol.py
4. sudo apt install python3-gpiozero
5. move service file to /etc/systemd/system
6. sudo systemctl daemon-reload
7. sudo systemctl enable [service]
8. sudo systemctl start [service]

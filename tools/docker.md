# Docker

Docker is a software for virtualising containers. Instead of running applications in the OS of the host system, applications are abstracted into containers that are separated from the host OS.

See also the official [install guide](https://docs.docker.com/engine/install/ubuntu/).

## Set up Docker's apt repository

```bash
sudo apt update
sudo apt install ca-certificates curl (gnupg)
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

## Install Docker

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker <username>
```

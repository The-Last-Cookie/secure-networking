# Matrix

Matrix is a decentralised protocol for creating a communication channel. It is also versatile because it works independently from the client.

*Note: This installation guide requires [Docker](/docker.md).*

## Install nginx

nginx is used as a reverse proxy on the server.

Make a new directory to store all program data, e.g. `/opt/reverse-proxy`.

Now paste the following file into `/opt/reverse-proxy/docker-compose.yml`:

```yml
services:
    proxy:
        image: "jwilder/nginx-proxy"
        container_name: "proxy"
        volumes:
            - "certs:/etc/nginx/certs"
            - "vhost:/etc/nginx/vhost.d"
            - "html:/usr/share/nginx/html"
            - "/run/docker.sock:/tmp/docker.sock:ro"
        networks: ["server"]
        restart: "always"
        ports:
            - "80:80"
            - "443:443"

    letsencrypt:
        image: "jrcs/letsencrypt-nginx-proxy-companion"
        container_name: "letsencrypt"
        volumes:
            - "certs:/etc/nginx/certs"
            - "vhost:/etc/nginx/vhost.d"
            - "html:/usr/share/nginx/html"
            - "/run/docker.sock:/var/run/docker.sock:ro"
        environment:
            NGINX_PROXY_CONTAINER: "proxy"
        networks: ["server"]
        restart: "always"
        depends_on: ["proxy"]

networks:
    server:
        external: true

volumes:
    certs:
    vhost:
    html:
```

Load the reverse proxy by creating a new docker network:

```sh
docker network create server
docker compose up -d
```

## Matrix Synapse

Synapse is the name of the Matrix protocol. You could call it the "backend".

Make a new directory to store all program data, e.g. `/opt/synapse`.

Save the following file in `opt/synapse/docker-compose.yml`:

```yml
services:
    synapse:
        image: "matrixdotorg/synapse:latest"
        container_name: "synapse"
        volumes:
            - "./data:/data"
        environment:
            VIRTUAL_HOST: "matrix.<DOMAIN>"
            VIRTUAL_PORT: 8008
            LETSENCRYPT_HOST: "matrix.<DOMAIN>"
            SYNAPSE_SERVER_NAME: "matrix.<DOMAIN>"
            SYNAPSE_REPORT_STATS: "yes"
        networks: ["server"]

networks:
    server:
        external: true
```

Create a data directory for synapse, i.e. `/opt/synapse/data`

Build synapse with `docker compose run --rm synapse generate`.

The generated `homeserver.yaml` file contains various configurations for the synapse server, two of which are of note:

- **TLS is set to false:** This is okay because the nginx proxy handles the external traffic.
- **`enable_registration` set to false**: In case you do not want to allow arbitrary registrations (default).

In the management interface of the server provider, the subdomain for Matrix (*matrix.domain.com*) must be added as a DNS record.

Now let synapse run with `docker compose up -d`.

### Federation

If federation is enabled, users are allowed to talk to users from other Matrix users without creating a new account on this local server.

Go into the `reverse-proxy` folder and add this to the `synapse-federation` file:

```txt
location /.well-known/matrix/server {
    return 200 '{"m.server": "matrix.<DOMAIN>:443"}';
}
```

In the `docker-compose.yml` (under `services` > `proxy` > `volumes`), add `./synapse-federation:/etc/nginx/vhost.d/matrix.<DOMAIN>`.

Now rebuild the reverse proxy container with `docker compose up -d proxy`.

### Creating new user

To create a new user, use the following command:

```sh
docker exec -it synapse register_new_matrix_user http://localhost:8008 --config /data/homeserver.yaml --user "<USERNAME>" --no-admin
```

If the `--no-admin` argument is omitted, you will be asked if the user should be an admin.

After entering the command, type in the password for the user.

This requires a `registration_shared_secret` to be set in your config file.

Remember to remove the `registration_shared_secret` and restart if you no-longer need it. Synapse must be restarted to pick up this change.

Rebuild synapse with `docker compose up -d synapse`.

## Synapse admin

There is a useful tool for managing user data for synapse which is called [Synapse Admin](https://github.com/Awesome-Technologies/synapse-admin).

From your local client, start a Synapse Admin instance with `docker run -p 8080:80 awesometechnologies/synapse-admin`.

Find out the container IP with `docker inspect CONTAINER_ID`.

Now, create a SSH tunnel for forwarding packets to your container instance:

`ssh -N -L 127.0.0.1:8008:CONTAINER_IP:8008 <user>@<domain>`

Access <http://localhost:8080> in your web browser.

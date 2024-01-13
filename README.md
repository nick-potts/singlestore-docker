# SingleStore Dockerized

Example of setting up SingleStore with Docker the hard way.

**NOTE**: You probably want to use the [official image](https://hub.docker.com/r/singlestore/cluster-in-a-box)

## Setup

Create keys:

```bash
ssh-keygen -f keys/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f keys/ssh_host_dsa_key -N '' -t dsa
```

## Setup env

Copy the example `.env`:

```sh
cp .env.example .env
```

Setup environment variables:

- `SDB_LICENSE`: The license of you SingleStore installation. This is available in the [SingleStore Portal](https://portal.singlestore.com).
- `SDB_PASSWORD`: The password for the instance.

## Start

Start the Docker container with `docker compose`:

```sh
docker compose up
```

## SSH

To log in to the container:

```sh
docker compose exec db bash
```

## Connect to DB

From within the container:

```sh
singlestore -h localhost -P 3306 -u root -p$SDB_PASSWORD
```

From the host machine:

```sh
mysql -h 127.0.0.1 \
  -P 3306 \
  -u root \
  --password=<your-password> \
  --prompt="singlestore> "
```

## Deployment

This can be deployed anywhere Docker is supported.

For example, it works great on [Railway](https://railway.app).

Just make sure to open port `3306`.

On Railway, the port can be exposed via the [TCP Port Proxy](https://docs.railway.app/guides/public-networking#tcp-proxying).

## License

MIT

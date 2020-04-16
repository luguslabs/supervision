# Supervisor
Supervisor permits the supervision of a Polkadot node.

Supervisor includes:
- Grafana
- Prometheus

# Build
```bash
docker build -t luguslabs/supervision .
```

# Run
```bash
docker run -d \
    -p 3000:3000  \
    --name supervision \
    -e GF_SECURITY_ADMIN_PASSWORD=<ADMIN_PASSWORD> \
    -e PROMETHEUS_TARGET=<POLKADOT_PROMETHEUS_ENDPOINT> \
    luguslabs/supervision
```
* `GF_SECURITY_ADMIN_PASSWORD` - password to access Grafana panel
* `PROMETHEUS_TARGET` - Polkadot node Prometheus endpoint `Default: localhost:9615`
* You can add `--network=container:<CONTAINER_ID>` to use networking of another container.

# Testing
## Launch polkadot node
```bash
docker run -d -p 3000:3000 --name polkadot parity/polkadot
```

## Launch supervisor
```bash
docker run -d \
    --name supervision \
    -e GF_SECURITY_ADMIN_PASSWORD=admin1 \
    -e PROMETHEUS_TARGET=localhost:9615 \
    --network=container:polkadot \
    luguslabs/supervision
```

## Go to dashboard
```bash
http://localhost:3000
---------------------
User: admin
Password: admin1
```

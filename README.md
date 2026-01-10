# emby-shenyihijack

A Docker Mod for LinuxServer.io containers that provides mitmproxy certificate installation and domain hijacking functionality.

## Features

1. **CA Certificate Installation**: Automatically installs the mitmproxy CA certificate to the system trust store (supports both Debian/Ubuntu and Alpine)
2. **Domain Hijacking**: Resolves a specified domain to an IP address and redirects a list of domains to that IP via `/etc/hosts`

## Usage

Add the following environment variable to your container:

```yaml
environment:
  - DOCKER_MODS=guowanghushifu/mods:emby-shenyihijack
  - SHENYI_HIJACKDOMAIN=mitmproxy  # Domain to resolve for the hijack IP
  - SHENYI_DOMAINLIST=example.com,api.example.com,cdn.example.com  # Comma-separated list of domains to hijack
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SHENYI_HIJACKDOMAIN` | The domain name to resolve to get the target IP address | Yes (for hosts hijacking) |
| `SHENYI_DOMAINLIST` | Comma-separated list of domain names to redirect to the hijack IP | Yes (for hosts hijacking) |

## Certificate Installation

The mod will look for a mitmproxy CA certificate at `/mitmproxy/mitmproxy-ca-cert.pem`. If the file exists, it will be installed to the system certificate store.

- The mod will retry up to 10 times with 1-second intervals if the certificate file is not immediately available
- This is useful when using a mitmproxy container that generates certificates at startup

## How It Works

### Certificate Installation
1. Waits for `/mitmproxy/mitmproxy-ca-cert.pem` to exist (retries up to 10 times)
2. Copies the certificate to `/usr/local/share/ca-certificates/`
3. Runs `update-ca-certificates` to install the certificate

### Domain Hijacking
1. Resolves `SHENYI_HIJACKDOMAIN` to an IPv4 address
2. Parses `SHENYI_DOMAINLIST` (comma-separated)
3. Adds each domain to `/etc/hosts` pointing to the resolved IP
4. Entries are marked with `# emby-shenyihijack` for identification

## Example docker-compose.yml

```yaml
version: "3.8"

services:
  mitmproxy:
    image: mitmproxy/mitmproxy
    container_name: mitmproxy
    command: mitmdump
    volumes:
      - mitmproxy-certs:/home/mitmproxy/.mitmproxy
    networks:
      - proxy-network

  emby:
    image: lscr.io/linuxserver/emby:latest
    container_name: emby
    environment:
      - DOCKER_MODS=guowanghushifu/mods:emby-shenyihijack
      - SHENYI_HIJACKDOMAIN=mitmproxy
      - SHENYI_DOMAINLIST=api.example.com,cdn.example.com
    volumes:
      - mitmproxy-certs:/mitmproxy:ro
    networks:
      - proxy-network
    depends_on:
      - mitmproxy

volumes:
  mitmproxy-certs:

networks:
  proxy-network:
```

## Building

The mod is automatically built and published to GitHub Container Registry when pushed to the main branch.

To build manually:

```bash
docker build -t emby-shenyihijack .
```

## License

MIT

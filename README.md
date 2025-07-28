# N8N Self-Hosting Setup

This repository contains a Docker Compose setup for self-hosting n8n with Traefik as a reverse proxy and automatic SSL certificates.

## Prerequisites

- Ubuntu/Debian server
- **Minimum**: 1 CPU, 2GB RAM (tested configuration)
- **Recommended**: 2 CPU, 4GB RAM for better performance
- Domain name with DNS pointing to your server
- Docker and Docker Compose installed

## Quick Start

1. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd n8n-self-host
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

3. **Run the setup script**
   ```bash
   chmod +x command.sh
   ./command.sh
   ```

## Configuration

### Environment Variables (.env file)

Create a `.env` file with the following variables:

```env
# Domain Configuration
DOMAIN_NAME=yourdomain.com
SUBDOMAIN=n8n

# SSL Configuration
SSL_EMAIL=your-email@yourdomain.com

# Timezone
GENERIC_TIMEZONE=UTC

# N8N Authentication (required)
N8N_USER=admin
N8N_PASSWORD=your-secure-password
```

### DNS Configuration

Ensure your domain points to your server:
- `n8n.yourdomain.com` → Your server's IP address

## Architecture

- **Traefik**: Reverse proxy with automatic SSL certificates
- **N8N**: Workflow automation platform
- **Volumes**: Persistent data storage

## Security Features

- Automatic HTTPS redirect
- HSTS headers
- XSS protection
- Content type sniffing protection
- Local port binding for n8n
- Basic authentication for n8n access

## Performance Optimizations

This setup is optimized for limited resources (1 CPU, 2GB RAM):
- Disabled metrics collection
- Reduced log verbosity
- Disabled diagnostics
- Optimized health check intervals
- Resource limits to prevent system overload

## Access

Once deployed, access n8n at: `https://n8n.yourdomain.com`

**Login credentials:**
- Username: `admin` (or value from N8N_USER)
- Password: Value from N8N_PASSWORD in your .env file

## Troubleshooting

### Check logs
```bash
docker compose logs -f n8n
docker compose logs -f traefik
```

### Restart services
```bash
docker compose restart
```

### Update n8n
```bash
docker compose pull n8n
docker compose up -d n8n
```

## Backup

Your n8n data is stored in the `n8n_data` volume. To backup:

```bash
docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup-$(date +%Y%m%d).tar.gz -C /data .
```

## License

This setup is for personal use. Please review n8n's licensing terms for commercial use.

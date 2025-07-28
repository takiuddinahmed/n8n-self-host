# N8N Self-Hosting Setup

This repository contains a Docker Compose setup for self-hosting n8n with Traefik as a reverse proxy and automatic SSL certificates.

**Current Configuration:**
- **Domain**: `n8n.takiuddin.me`
- **Timezone**: `Asia/Dhaka`
- **Resources**: Optimized for 1 CPU, 2GB RAM

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
   # The .env file is already configured for takiuddin.me
   # If you need to modify it, edit the .env file directly
   ```

3. **Run the setup script**
   ```bash
   chmod +x command.sh
   ./command.sh
   ```

## Configuration

### Environment Variables (.env file)

The `.env` file is already configured with the following values:

```env
# Domain Configuration
DOMAIN_NAME=takiuddin.me
SUBDOMAIN=n8n

# SSL Configuration
SSL_EMAIL=takiuddinahmed@gmail.com

# Timezone
GENERIC_TIMEZONE=Asia/Dhaka

# N8N Authentication (required)
N8N_USER=admin
N8N_PASSWORD=your-secure-password  # ⚠️ Change this to a secure password
```

### DNS Configuration

Ensure your domain points to your server:
- `n8n.takiuddin.me` → Your Compute Engine IP address

**DNS Record Example:**
```
Type: A
Name: n8n
Value: YOUR_COMPUTE_ENGINE_IP
TTL: 300
```

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

Once deployed, access n8n at: **https://n8n.takiuddin.me**

**Login credentials:**
- Username: `admin`
- Password: Value from N8N_PASSWORD in your .env file

**⚠️ Important**: Make sure to change the default password in your `.env` file before deployment!

## Troubleshooting

### Check logs
```bash
docker compose logs -f n8n
docker compose logs -f traefik
```

### Common Issues

**1. SSL Certificate Issues**
- Ensure DNS is properly configured for `n8n.takiuddin.me`
- Check that ports 80 and 443 are open on your Compute Engine firewall

**2. Memory Issues (1 CPU, 2GB RAM)**
- Monitor memory usage: `docker stats`
- If running out of memory, reduce concurrent workflows
- Consider upgrading to 2 CPU, 4GB RAM for better performance

**3. Slow Startup**
- First startup may take 3-5 minutes on limited resources
- Check logs for any errors: `docker compose logs -f`

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

## Deployment Checklist

Before running `./command.sh`:

- [ ] DNS configured: `n8n.takiuddin.me` → Your Compute Engine IP
- [ ] Firewall rules: Ports 80 and 443 open
- [ ] Password updated: Change `N8N_PASSWORD` in `.env` file
- [ ] Compute Engine: Ubuntu 20.04+ with 1 CPU, 2GB RAM minimum

## License

This setup is for personal use. Please review n8n's licensing terms for commercial use.

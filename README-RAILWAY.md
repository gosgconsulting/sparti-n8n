# sparti-n8n Railway Deployment

This repository contains a Railway.com deployment configuration for the sparti-n8n (Self-hosted AI Starter Kit) project.

## Quick Start

### Prerequisites
- [Railway.com account](https://railway.app)
- [Railway CLI](https://docs.railway.app/develop/cli) installed
- Git repository access

### One-Click Deploy (Recommended)

Click the button below to deploy directly to Railway:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/your-template-id)

### Manual Deployment

1. **Clone and Setup**
   ```bash
   git clone <your-repo-url>
   cd sparti-n8n
   cp env.example .env
   # Edit .env with your values
   ```

2. **Deploy with Script**
   
   **Windows (PowerShell):**
   ```powershell
   .\scripts\deploy-to-railway.ps1
   .\scripts\configure-env-vars.ps1
   ```
   
   **Linux/Mac:**
   ```bash
   ./scripts/deploy-to-railway.sh
   ./scripts/configure-env-vars.sh
   ```

3. **Access Your Deployment**
   
   After deployment, check your Railway dashboard for service URLs.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Railway Project                           │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│     n8n     │ PostgreSQL  │   Ollama    │     Qdrant      │
│   Web App   │  Database   │ LLM Service │ Vector Database │
│   :5678     │   :5432     │   :11434    │     :6333       │
└─────────────┴─────────────┴─────────────┴─────────────────┘
```

## Services

| Service | Purpose | Port | Storage |
|---------|---------|------|---------|
| **n8n** | Workflow automation platform | 5678 | 10GB |
| **PostgreSQL** | Primary database | 5432 | Managed |
| **Ollama** | Local LLM inference | 11434 | 20GB |
| **Qdrant** | Vector database | 6333 | 10GB |

## Environment Variables

### Required Variables

Create a `.env` file with these values:

```env
# PostgreSQL
POSTGRES_USER=n8n
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=n8n

# n8n Security
N8N_ENCRYPTION_KEY=your_32_char_encryption_key
N8N_USER_MANAGEMENT_JWT_SECRET=your_jwt_secret

# Optional
CUSTOM_DOMAIN=your-domain.com
```

### Auto-Generated Variables

The deployment scripts will automatically generate secure values for:
- `N8N_ENCRYPTION_KEY`
- `N8N_USER_MANAGEMENT_JWT_SECRET`
- `POSTGRES_PASSWORD`

## File Structure

```
sparti-n8n/
├── scripts/
│   ├── deploy-to-railway.sh      # Linux/Mac deployment
│   ├── deploy-to-railway.ps1     # Windows deployment
│   ├── configure-env-vars.sh     # Linux/Mac env setup
│   └── configure-env-vars.ps1    # Windows env setup
├── Dockerfile.n8n               # n8n service container
├── Dockerfile.ollama            # Ollama service container
├── Dockerfile.qdrant            # Qdrant service container
├── docker-compose.railway.yml   # Local testing
├── railway.json                 # Railway build config
├── railway.toml                 # Railway service config
├── railway-services.yml         # Service definitions
├── env.example                  # Environment template
├── RAILWAY_DEPLOYMENT.md        # Detailed deployment guide
└── README-RAILWAY.md           # This file
```

## Local Development

Test your Railway configuration locally:

```bash
# Copy environment variables
cp env.example .env
# Edit .env with your values

# Start services locally
docker-compose -f docker-compose.railway.yml up
```

Access services:
- n8n: http://localhost:5678
- Qdrant: http://localhost:6333
- Ollama: http://localhost:11434

## Deployment Process

### Automatic Deployment

1. **Fork this repository**
2. **Connect to Railway**
   - Login to Railway.app
   - Create new project from GitHub repo
   - Railway will auto-detect the configuration

3. **Configure Environment Variables**
   - Set required variables in Railway dashboard
   - Or use the configuration scripts

4. **Deploy**
   - Railway automatically builds and deploys
   - Monitor progress in Railway dashboard

### Manual Deployment Steps

1. **Initialize Railway Project**
   ```bash
   railway login
   railway init
   railway link # Optional: link to GitHub
   ```

2. **Create Services**
   ```bash
   railway add postgresql --name postgres
   railway service new n8n
   railway service new ollama  
   railway service new qdrant
   ```

3. **Configure Environment Variables**
   ```bash
   # Use the provided scripts or set manually
   railway variables set KEY=value --service n8n
   ```

4. **Deploy Services**
   ```bash
   railway up --service postgres
   railway up --service qdrant
   railway up --service ollama
   railway up --service n8n
   ```

## Post-Deployment Setup

### 1. Access n8n Interface

Visit your Railway-provided URL to access n8n.

### 2. Import Demo Data

```bash
railway shell --service n8n
n8n import:credentials --separate --input=/demo-data/credentials
n8n import:workflow --separate --input=/demo-data/workflows
```

### 3. Configure AI Services

In n8n:
- **Ollama**: Set base URL to `http://ollama.railway.internal:11434`
- **Qdrant**: Set host to `qdrant.railway.internal:6333`

## Monitoring

### Health Checks

All services include health checks:
- **n8n**: `GET /healthz`
- **Ollama**: `GET /api/tags`
- **Qdrant**: `GET /health`
- **PostgreSQL**: Railway managed

### Logs

Access logs via Railway dashboard or CLI:
```bash
railway logs --service n8n
railway logs --service ollama
```

### Metrics

Monitor in Railway dashboard:
- CPU usage
- Memory usage
- Network traffic
- Disk usage

## Scaling

### Vertical Scaling
Adjust CPU/Memory in Railway dashboard per service.

### Horizontal Scaling
Configure replicas for stateless services (n8n).

### Resource Recommendations

| Service | CPU | Memory | Storage |
|---------|-----|--------|---------|
| n8n | 1 vCPU | 2GB | 10GB |
| Ollama | 2 vCPU | 4GB | 20GB |
| Qdrant | 1 vCPU | 2GB | 10GB |
| PostgreSQL | 1 vCPU | 1GB | Railway managed |

## Troubleshooting

### Common Issues

**Service Won't Start**
- Check environment variables
- Review service logs
- Verify resource limits

**Connection Issues**
- Verify internal DNS names
- Check port configurations
- Review networking settings

**Ollama Model Download**
- Initial startup takes 5-10 minutes
- Check logs for download progress
- Ensure sufficient storage

### Support Channels

- **Railway**: [Railway Discord](https://discord.gg/railway)
- **n8n**: [n8n Community](https://community.n8n.io/)
- **Project Issues**: [GitHub Issues](https://github.com/your-repo/issues)

## Cost Optimization

- **Development**: Enable sleep mode
- **Production**: Use appropriate resource limits
- **Storage**: Regular cleanup of unused data
- **Monitoring**: Set up usage alerts

## Security

- **Environment Variables**: Use Railway's secret management
- **Network**: Services communicate via private network
- **Authentication**: Configure n8n user management
- **Updates**: Regular security updates

## Advanced Configuration

### Custom Domains

```bash
railway domain add your-domain.com --service n8n
```

### SSL Certificates

Railway automatically provides SSL certificates.

### Backup Strategy

- **PostgreSQL**: Railway automatic backups
- **n8n Workflows**: Regular exports
- **Ollama Models**: Re-download on need
- **Qdrant Data**: Periodic exports

### CI/CD Integration

Connect GitHub repository for automatic deployments:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Railway
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: railway deploy
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## Quick Commands

```bash
# Check status
railway status

# View logs
railway logs --service n8n

# Access shell
railway shell --service n8n

# Restart service
railway restart --service n8n

# Update variables
railway variables set KEY=value --service n8n

# Scale service
railway scale --service n8n --replicas 2
```

Ready to deploy? Start with the Quick Start section above! 🚀

# Railway.com Deployment Guide for sparti-n8n

This guide walks you through deploying the sparti-n8n (Self-hosted AI Starter Kit) to Railway.com.

## Overview

The sparti-n8n project consists of four main services:
- **n8n**: The main workflow automation platform
- **PostgreSQL**: Database for n8n data persistence
- **Ollama**: Local LLM inference server
- **Qdrant**: Vector database for AI operations

## Prerequisites

1. [Railway.com account](https://railway.app)
2. [Railway CLI](https://docs.railway.app/develop/cli) installed
3. Git repository with this codebase
4. Basic understanding of environment variables

## Deployment Architecture

Railway will deploy each service as a separate container with the following configuration:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│     n8n     │    │ PostgreSQL  │    │   Ollama    │    │   Qdrant    │
│   :5678     │◄──►│   :5432     │    │  :11434     │    │   :6333     │
│             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       └───────────────────┼───────────────────┼───────────────────┘
                          │                   │
                    Railway Private Network
```

## Step-by-Step Deployment

### 1. Prepare Your Repository

Ensure your repository contains all the files created in this deployment plan:
- `railway.json`
- `env.example`
- `Dockerfile.n8n`
- `Dockerfile.ollama`
- `Dockerfile.qdrant`
- `docker-compose.railway.yml`

### 2. Initialize Railway Project

```bash
# Login to Railway
railway login

# Initialize project from your repository
railway init

# Link to your GitHub repository (optional but recommended)
railway link
```

### 3. Create Railway Services

You'll need to create four separate services. Run these commands in your project directory:

```bash
# Create PostgreSQL service
railway add --database postgresql

# Create n8n service
railway add

# Create Ollama service  
railway add

# Create Qdrant service
railway add
```

### 4. Configure Environment Variables

For each service, set the required environment variables:

#### PostgreSQL Service
Railway automatically configures PostgreSQL. Note the generated `DATABASE_URL`.

#### n8n Service
```bash
railway variables set N8N_ENCRYPTION_KEY="your-32-char-encryption-key-here"
railway variables set N8N_USER_MANAGEMENT_JWT_SECRET="your-jwt-secret-here"
railway variables set DB_TYPE="postgresdb"
railway variables set DB_POSTGRESDB_HOST="postgres.railway.internal"
railway variables set DB_POSTGRESDB_USER="postgres"
railway variables set DB_POSTGRESDB_PASSWORD="${{Postgres.PGPASSWORD}}"
railway variables set DB_POSTGRESDB_DATABASE="railway"
railway variables set OLLAMA_HOST="ollama.railway.internal:11434"
railway variables set N8N_HOST="0.0.0.0"
railway variables set N8N_PORT="5678"
railway variables set WEBHOOK_URL="https://${{RAILWAY_STATIC_URL}}"
```

#### Ollama Service
```bash
railway variables set OLLAMA_HOST="0.0.0.0:11434"
railway variables set OLLAMA_KEEP_ALIVE="24h"
```

#### Qdrant Service
```bash
railway variables set QDRANT__SERVICE__HTTP_PORT="6333"
railway variables set QDRANT__SERVICE__HOST="0.0.0.0"
```

### 5. Configure Service Networking

Railway services communicate via private networking using the pattern `{service-name}.railway.internal`.

Update your n8n service environment to reference other services:
- PostgreSQL: `postgres.railway.internal:5432`
- Ollama: `ollama.railway.internal:11434`  
- Qdrant: `qdrant.railway.internal:6333`

### 6. Set up Dockerfiles for Each Service

Create a `railway.toml` file in your repository root:

```toml
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile.n8n"

[deploy]
numReplicas = 1
sleepApplication = false
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

For other services, specify their respective Dockerfiles.

### 7. Configure Persistent Storage

Railway automatically provides persistent storage. For data that needs to persist:

- PostgreSQL: Automatic via Railway's managed database
- n8n: Mount volume for `/home/node/.n8n`
- Ollama: Mount volume for `/root/.ollama` 
- Qdrant: Mount volume for `/qdrant/storage`

### 8. Deploy Services

Deploy each service:

```bash
# Deploy PostgreSQL (if not using Railway's managed database)
railway up --service postgres

# Deploy Qdrant
railway up --service qdrant

# Deploy Ollama
railway up --service ollama

# Deploy n8n (depends on other services)
railway up --service n8n
```

### 9. Configure Domain and SSL

Railway automatically provides HTTPS domains. To use a custom domain:

```bash
railway domain add yourdomain.com
```

### 10. Import Demo Data

Once n8n is running, import the demo workflows and credentials:

```bash
# Access the n8n container
railway shell

# Import credentials and workflows
n8n import:credentials --separate --input=/demo-data/credentials
n8n import:workflow --separate --input=/demo-data/workflows
```

## Post-Deployment Configuration

### 1. Access n8n Interface

Visit your Railway-provided URL (e.g., `https://n8n-production-xxx.up.railway.app`) to access the n8n interface.

### 2. Configure Ollama Connection

In n8n:
1. Go to Settings → Credentials
2. Add "Ollama" credential
3. Set Base URL to `http://ollama.railway.internal:11434`

### 3. Configure Qdrant Connection

In n8n:
1. Add Qdrant credentials
2. Set Host to `qdrant.railway.internal`
3. Set Port to `6333`

## Monitoring and Maintenance

### Health Checks

Each service includes health checks:
- n8n: `GET /healthz`
- Ollama: `GET /api/tags`
- Qdrant: `GET /health`
- PostgreSQL: Railway managed

### Logs and Monitoring

Access logs via Railway dashboard or CLI:
```bash
railway logs --service n8n
railway logs --service ollama
railway logs --service qdrant
```

### Scaling

Configure scaling in Railway dashboard:
- CPU: Adjust based on workload
- Memory: Ollama requires more memory for larger models
- Replicas: Scale horizontally if needed

### Backups

- PostgreSQL: Railway automatic backups
- n8n workflows: Export via n8n interface
- Ollama models: Will re-download on restart
- Qdrant data: Configure periodic exports

## Troubleshooting

### Common Issues

1. **Docker Build Errors**
   - If you encounter `mkdir` permission errors, ensure the Dockerfile uses `USER root` for setup
   - The provided Dockerfiles have been optimized to avoid common permission issues
   - Use `--chown` flag when copying files to set proper ownership

2. **Service Connection Issues**
   - Verify internal DNS names (*.railway.internal)
   - Check environment variables in Railway dashboard
   - Review service logs for connection errors

3. **Ollama Model Download**
   - First startup takes 5-10 minutes to download models
   - Check logs for download progress: `railway logs --service ollama`
   - Ensure sufficient disk space (20GB+ recommended)

4. **n8n Database Connection**
   - Verify PostgreSQL credentials match between services
   - Check database URL format in environment variables
   - Ensure database service is running and healthy

### Support

- Railway Documentation: https://docs.railway.app
- n8n Documentation: https://docs.n8n.io
- Community Support: Railway Discord, n8n Forum

## Cost Optimization

- Enable sleep mode for development environments
- Monitor resource usage in Railway dashboard
- Use appropriate CPU/memory limits
- Consider using Railway's managed PostgreSQL for production

## Security Considerations

- Use strong encryption keys and JWT secrets
- Enable Railway's private networking
- Configure proper firewall rules
- Regular security updates
- Monitor access logs

---

## Quick Commands Reference

```bash
# Deploy all services
railway up

# Check service status
railway status

# View logs
railway logs

# Access service shell
railway shell --service n8n

# Update environment variables
railway variables set KEY=value

# Restart service
railway restart --service n8n
```

This completes the Railway deployment setup for sparti-n8n!

# Railway Deployment Checklist

Use this checklist to ensure a successful deployment of sparti-n8n to Railway.com.

## Pre-Deployment ✅

### Prerequisites
- [ ] Railway.com account created
- [ ] Railway CLI installed (`npm install -g @railway/cli`)
- [ ] Git repository with sparti-n8n code
- [ ] Environment variables prepared

### Repository Setup
- [ ] All deployment files present:
  - [ ] `railway.json`
  - [ ] `railway.toml` 
  - [ ] `Dockerfile.n8n`
  - [ ] `Dockerfile.ollama`
  - [ ] `Dockerfile.qdrant`
  - [ ] `env.example`
  - [ ] Deployment scripts (`scripts/`)
- [ ] `.env` file created from `env.example`
- [ ] Environment variables configured with secure values

## Deployment Process ✅

### Railway Project Setup
- [ ] Logged into Railway CLI (`railway login`)
- [ ] Railway project initialized (`railway init`)
- [ ] Repository linked to Railway (optional: `railway link`)

### Service Creation
- [ ] PostgreSQL database service created
- [ ] n8n service created
- [ ] Ollama service created  
- [ ] Qdrant service created

### Environment Variables Configuration
- [ ] PostgreSQL variables set:
  - [ ] `POSTGRES_USER`
  - [ ] `POSTGRES_PASSWORD`
  - [ ] `POSTGRES_DB`
- [ ] n8n variables set:
  - [ ] `N8N_ENCRYPTION_KEY`
  - [ ] `N8N_USER_MANAGEMENT_JWT_SECRET`
  - [ ] Database connection variables
  - [ ] Service networking variables
- [ ] Ollama variables set:
  - [ ] `OLLAMA_HOST`
  - [ ] `OLLAMA_KEEP_ALIVE`
- [ ] Qdrant variables set:
  - [ ] `QDRANT__SERVICE__HTTP_PORT`
  - [ ] `QDRANT__SERVICE__HOST`

### Service Deployment
- [ ] PostgreSQL service deployed and healthy
- [ ] Qdrant service deployed and healthy
- [ ] Ollama service deployed and healthy (may take 5-10 minutes for model download)
- [ ] n8n service deployed and healthy

## Post-Deployment Verification ✅

### Service Health Checks
- [ ] All services showing "Active" status in Railway dashboard
- [ ] Health check endpoints responding:
  - [ ] n8n: `/healthz`
  - [ ] Ollama: `/api/tags`
  - [ ] Qdrant: `/health`
- [ ] No error logs in Railway dashboard

### Connectivity Tests
- [ ] n8n web interface accessible via Railway URL
- [ ] n8n can connect to PostgreSQL database
- [ ] n8n can connect to Ollama service
- [ ] n8n can connect to Qdrant service
- [ ] Internal service networking working (*.railway.internal domains)

### Demo Data Import
- [ ] Accessed n8n shell: `railway shell --service n8n`
- [ ] Imported credentials: `n8n import:credentials --separate --input=/demo-data/credentials`
- [ ] Imported workflows: `n8n import:workflow --separate --input=/demo-data/workflows`
- [ ] Demo workflow visible in n8n interface

### Functional Testing
- [ ] Can create new n8n account/login
- [ ] Can access demo workflow: `/workflow/srOnR8PAY3u4RSwb`
- [ ] Demo workflow executes successfully
- [ ] Chat interface responds (may take time for first Ollama model load)
- [ ] AI responses working correctly

## Production Readiness ✅

### Security Configuration
- [ ] Strong encryption keys generated and saved securely
- [ ] Environment variables properly secured in Railway
- [ ] No secrets committed to repository
- [ ] User authentication configured in n8n

### Performance Optimization
- [ ] Appropriate resource limits set for each service:
  - [ ] n8n: 1-2 vCPU, 2-4GB RAM
  - [ ] Ollama: 2-4 vCPU, 4-8GB RAM  
  - [ ] Qdrant: 1-2 vCPU, 2-4GB RAM
  - [ ] PostgreSQL: Railway managed
- [ ] Storage volumes properly sized
- [ ] Auto-scaling configured if needed

### Monitoring Setup
- [ ] Railway dashboard monitoring configured
- [ ] Log aggregation working
- [ ] Alert notifications set up
- [ ] Usage limits configured

### Backup and Recovery
- [ ] PostgreSQL backup strategy confirmed (Railway managed)
- [ ] n8n workflow export procedure documented
- [ ] Recovery process tested
- [ ] Data retention policies defined

## Optional Enhancements ✅

### Custom Domain
- [ ] Custom domain configured: `railway domain add yourdomain.com`
- [ ] DNS records updated
- [ ] SSL certificate verified
- [ ] Webhook URLs updated with custom domain

### CI/CD Pipeline
- [ ] GitHub repository connected for auto-deploy
- [ ] Branch-based deployments configured
- [ ] Deployment environments set up (dev/staging/prod)
- [ ] Rollback procedures tested

### Advanced Configuration
- [ ] Network policies configured
- [ ] Resource quotas set
- [ ] Cost monitoring enabled
- [ ] Performance metrics tracking

## Troubleshooting Checklist ✅

### Common Issues to Check
- [ ] Service startup order (dependencies)
- [ ] Environment variable typos
- [ ] Port configuration mismatches
- [ ] Internal DNS resolution issues
- [ ] Resource limit exceeded
- [ ] Storage volume mounting problems

### Debugging Commands
- [ ] Check service status: `railway status`
- [ ] View logs: `railway logs --service <service-name>`
- [ ] Access shell: `railway shell --service <service-name>`
- [ ] Test connectivity: `ping service.railway.internal`

## Sign-off ✅

### Stakeholder Approval
- [ ] Technical validation completed
- [ ] Performance requirements met
- [ ] Security review passed
- [ ] Documentation provided
- [ ] Support procedures defined

### Go-Live
- [ ] Production deployment successful
- [ ] Monitoring active
- [ ] Team trained on Railway platform
- [ ] Incident response procedures in place
- [ ] Success criteria met

---

## Quick Commands Reference

```bash
# Check everything is working
railway status
railway logs --service n8n
railway logs --service ollama

# Access services
railway shell --service n8n
curl https://your-n8n-url.railway.app/healthz

# Monitor resources
railway dashboard # Opens web dashboard
```

## Emergency Contacts

- **Railway Support**: [Railway Discord](https://discord.gg/railway)
- **n8n Community**: [n8n Forum](https://community.n8n.io/)
- **Project Maintainer**: [GitHub Issues](https://github.com/your-repo/issues)

---

**Deployment Date**: ___________  
**Deployed By**: ___________  
**Railway Project URL**: ___________  
**n8n Access URL**: ___________

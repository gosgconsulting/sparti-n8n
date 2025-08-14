# PowerShell Railway Deployment Script for sparti-n8n
# This script automates the deployment process to Railway.com

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Railway deployment for sparti-n8n..." -ForegroundColor Green

# Check if Railway CLI is installed
try {
    railway --version | Out-Null
} catch {
    Write-Host "❌ Railway CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g @railway/cli" -ForegroundColor Yellow
    exit 1
}

# Check if user is logged in
try {
    railway whoami | Out-Null
} catch {
    Write-Host "🔐 Please login to Railway first:" -ForegroundColor Yellow
    railway login
}

# Initialize project if not already done
if (-not (Test-Path ".railway")) {
    Write-Host "📦 Initializing Railway project..." -ForegroundColor Blue
    railway init
}

# Create environment file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Blue
    Copy-Item "env.example" ".env"
    Write-Host "⚠️  Please update the .env file with your actual values before continuing!" -ForegroundColor Yellow
    Write-Host "Press Enter when ready to continue..."
    Read-Host
}

# Deploy PostgreSQL service
Write-Host "🗄️  Setting up PostgreSQL database..." -ForegroundColor Blue
railway add postgresql --name postgres

# Deploy Qdrant service
Write-Host "🔍 Deploying Qdrant vector database..." -ForegroundColor Blue
railway service new qdrant
railway up --service qdrant --dockerfile Dockerfile.qdrant

# Deploy Ollama service
Write-Host "🤖 Deploying Ollama LLM service..." -ForegroundColor Blue
railway service new ollama
railway up --service ollama --dockerfile Dockerfile.ollama

# Deploy n8n service
Write-Host "⚡ Deploying n8n workflow service..." -ForegroundColor Blue
railway service new n8n
railway up --service n8n --dockerfile Dockerfile.n8n

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:"
Write-Host "1. Configure environment variables for each service"
Write-Host "2. Set up custom domain (optional)"
Write-Host "3. Import demo workflows"
Write-Host "4. Test the deployment"
Write-Host ""
Write-Host "🌐 Access your services:"
Write-Host "- n8n: Check Railway dashboard for the generated URL"
Write-Host "- View all services: railway status"
Write-Host ""
Write-Host "📚 For detailed configuration, see RAILWAY_DEPLOYMENT.md"

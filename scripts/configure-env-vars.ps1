# PowerShell Environment Variables Configuration Script for Railway
# This script helps configure all necessary environment variables for each service

$ErrorActionPreference = "Stop"

Write-Host "🔧 Configuring environment variables for Railway services..." -ForegroundColor Green

# Function to generate secure random keys
function Generate-Key {
    return [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(24))
}

function Generate-JWTSecret {
    return [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
}

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found. Please create one from env.example first." -ForegroundColor Red
    exit 1
}

# Read environment variables from .env file
$envVars = @{}
Get-Content ".env" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.*)$") {
        $envVars[$matches[1]] = $matches[2]
    }
}

# Set default values if not provided
$N8N_ENCRYPTION_KEY = if ($envVars["N8N_ENCRYPTION_KEY"]) { $envVars["N8N_ENCRYPTION_KEY"] } else { Generate-Key }
$N8N_USER_MANAGEMENT_JWT_SECRET = if ($envVars["N8N_USER_MANAGEMENT_JWT_SECRET"]) { $envVars["N8N_USER_MANAGEMENT_JWT_SECRET"] } else { Generate-JWTSecret }
$POSTGRES_PASSWORD = if ($envVars["POSTGRES_PASSWORD"]) { $envVars["POSTGRES_PASSWORD"] } else { Generate-Key }
$POSTGRES_USER = if ($envVars["POSTGRES_USER"]) { $envVars["POSTGRES_USER"] } else { "n8n" }
$POSTGRES_DB = if ($envVars["POSTGRES_DB"]) { $envVars["POSTGRES_DB"] } else { "n8n" }

Write-Host "🔐 Setting up PostgreSQL environment variables..." -ForegroundColor Blue
railway variables set "POSTGRES_USER=$POSTGRES_USER" --service postgres
railway variables set "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" --service postgres
railway variables set "POSTGRES_DB=$POSTGRES_DB" --service postgres

Write-Host "⚡ Setting up n8n environment variables..." -ForegroundColor Blue
railway variables set "N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY" --service n8n
railway variables set "N8N_USER_MANAGEMENT_JWT_SECRET=$N8N_USER_MANAGEMENT_JWT_SECRET" --service n8n
railway variables set "DB_TYPE=postgresdb" --service n8n
railway variables set "DB_POSTGRESDB_HOST=postgres.railway.internal" --service n8n
railway variables set "DB_POSTGRESDB_PORT=5432" --service n8n
railway variables set "DB_POSTGRESDB_USER=$POSTGRES_USER" --service n8n
railway variables set "DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD" --service n8n
railway variables set "DB_POSTGRESDB_DATABASE=$POSTGRES_DB" --service n8n
railway variables set "OLLAMA_HOST=ollama.railway.internal:11434" --service n8n
railway variables set "N8N_HOST=0.0.0.0" --service n8n
railway variables set "N8N_PORT=5678" --service n8n
railway variables set "N8N_PROTOCOL=http" --service n8n
railway variables set "N8N_DIAGNOSTICS_ENABLED=false" --service n8n
railway variables set "N8N_PERSONALIZATION_ENABLED=false" --service n8n

Write-Host "🤖 Setting up Ollama environment variables..." -ForegroundColor Blue
railway variables set "OLLAMA_HOST=0.0.0.0:11434" --service ollama
railway variables set "OLLAMA_KEEP_ALIVE=24h" --service ollama

Write-Host "🔍 Setting up Qdrant environment variables..." -ForegroundColor Blue
railway variables set "QDRANT__SERVICE__HTTP_PORT=6333" --service qdrant
railway variables set "QDRANT__SERVICE__HOST=0.0.0.0" --service qdrant

Write-Host "✅ Environment variables configured successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Generated secrets (save these securely):" -ForegroundColor Yellow
Write-Host "N8N_ENCRYPTION_KEY: $N8N_ENCRYPTION_KEY"
Write-Host "N8N_USER_MANAGEMENT_JWT_SECRET: $N8N_USER_MANAGEMENT_JWT_SECRET"
Write-Host "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
Write-Host ""
Write-Host "🚀 You can now deploy your services with: railway up" -ForegroundColor Green

#!/bin/bash

# Environment Variables Configuration Script for Railway
# This script helps configure all necessary environment variables for each service

set -e

echo "🔧 Configuring environment variables for Railway services..."

# Generate secure random keys if not provided
generate_key() {
    openssl rand -hex 16
}

generate_jwt_secret() {
    openssl rand -base64 32
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Please create one from env.example first."
    exit 1
fi

# Source environment variables
source .env

# Set default values if not provided
N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY:-$(generate_key)}
N8N_USER_MANAGEMENT_JWT_SECRET=${N8N_USER_MANAGEMENT_JWT_SECRET:-$(generate_jwt_secret)}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-$(generate_key)}

echo "🔐 Setting up PostgreSQL environment variables..."
railway variables set POSTGRES_USER="$POSTGRES_USER" --service postgres
railway variables set POSTGRES_PASSWORD="$POSTGRES_PASSWORD" --service postgres
railway variables set POSTGRES_DB="$POSTGRES_DB" --service postgres

echo "⚡ Setting up n8n environment variables..."
railway variables set N8N_ENCRYPTION_KEY="$N8N_ENCRYPTION_KEY" --service n8n
railway variables set N8N_USER_MANAGEMENT_JWT_SECRET="$N8N_USER_MANAGEMENT_JWT_SECRET" --service n8n
railway variables set DB_TYPE="postgresdb" --service n8n
railway variables set DB_POSTGRESDB_HOST="postgres.railway.internal" --service n8n
railway variables set DB_POSTGRESDB_PORT="5432" --service n8n
railway variables set DB_POSTGRESDB_USER="$POSTGRES_USER" --service n8n
railway variables set DB_POSTGRESDB_PASSWORD="$POSTGRES_PASSWORD" --service n8n
railway variables set DB_POSTGRESDB_DATABASE="$POSTGRES_DB" --service n8n
railway variables set OLLAMA_HOST="ollama.railway.internal:11434" --service n8n
railway variables set N8N_HOST="0.0.0.0" --service n8n
railway variables set N8N_PORT="5678" --service n8n
railway variables set N8N_PROTOCOL="http" --service n8n
railway variables set N8N_DIAGNOSTICS_ENABLED="false" --service n8n
railway variables set N8N_PERSONALIZATION_ENABLED="false" --service n8n

echo "🤖 Setting up Ollama environment variables..."
railway variables set OLLAMA_HOST="0.0.0.0:11434" --service ollama
railway variables set OLLAMA_KEEP_ALIVE="24h" --service ollama

echo "🔍 Setting up Qdrant environment variables..."
railway variables set QDRANT__SERVICE__HTTP_PORT="6333" --service qdrant
railway variables set QDRANT__SERVICE__HOST="0.0.0.0" --service qdrant

echo "✅ Environment variables configured successfully!"
echo ""
echo "📝 Generated secrets (save these securely):"
echo "N8N_ENCRYPTION_KEY: $N8N_ENCRYPTION_KEY"
echo "N8N_USER_MANAGEMENT_JWT_SECRET: $N8N_USER_MANAGEMENT_JWT_SECRET"
echo "POSTGRES_PASSWORD: $POSTGRES_PASSWORD"
echo ""
echo "🚀 You can now deploy your services with: railway up"

#!/bin/bash

# Railway Deployment Script for sparti-n8n
# This script automates the deployment process to Railway.com

set -e

echo "🚀 Starting Railway deployment for sparti-n8n..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI is not installed. Please install it first:"
    echo "npm install -g @railway/cli"
    exit 1
fi

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo "🔐 Please login to Railway first:"
    railway login
fi

# Initialize project if not already done
if [ ! -f ".railway" ]; then
    echo "📦 Initializing Railway project..."
    railway init
fi

# Create environment file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "⚠️  Please update the .env file with your actual values before continuing!"
    echo "Press Enter when ready to continue..."
    read
fi

# Deploy PostgreSQL service
echo "🗄️  Setting up PostgreSQL database..."
railway add postgresql --name postgres

# Deploy Qdrant service
echo "🔍 Deploying Qdrant vector database..."
railway service new qdrant
railway up --service qdrant --dockerfile Dockerfile.qdrant

# Deploy Ollama service
echo "🤖 Deploying Ollama LLM service..."
railway service new ollama
railway up --service ollama --dockerfile Dockerfile.ollama

# Deploy n8n service
echo "⚡ Deploying n8n workflow service..."
railway service new n8n
railway up --service n8n --dockerfile Dockerfile.n8n

echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Configure environment variables for each service"
echo "2. Set up custom domain (optional)"
echo "3. Import demo workflows"
echo "4. Test the deployment"
echo ""
echo "🌐 Access your services:"
echo "- n8n: Check Railway dashboard for the generated URL"
echo "- View all services: railway status"
echo ""
echo "📚 For detailed configuration, see RAILWAY_DEPLOYMENT.md"

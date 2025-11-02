#!/bin/bash
# Environment setup script for BTC Trading Platform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Setting up BTC Trading Platform environment..."

# Check Python version
echo "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
REQUIRED_VERSION="3.14"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "Error: Python 3.14+ is required. Found: $PYTHON_VERSION"
    exit 1
fi

# Create virtual environment
echo "Creating virtual environment..."
cd "$PROJECT_ROOT"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip setuptools wheel

# Install project dependencies
echo "Installing project dependencies..."
pip install -e .

# Install development dependencies
echo "Installing development dependencies..."
pip install -e ".[dev]"

# Create .env file from .env.example if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your configuration before running the application."
else
    echo ".env file already exists, skipping..."
fi

# Create data directories
echo "Creating data directories..."
mkdir -p data/historical
mkdir -p data/logs

# Check if Docker is available
if command -v docker &> /dev/null; then
    echo "Docker is available. You can use docker-compose to run the database."
    echo "  docker-compose -f docker/docker-compose.yml up -d postgres"
else
    echo "⚠️  Docker is not installed. Database setup will require manual PostgreSQL installation."
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .env file with your configuration"
echo "  2. Start database: docker-compose -f docker/docker-compose.yml up -d postgres"
echo "  3. Run migrations: ./scripts/migrate.sh"
echo "  4. Activate virtual environment: source venv/bin/activate"
echo "  5. Run tests: pytest"
echo "  6. Run application: python -m cli.manage --help"


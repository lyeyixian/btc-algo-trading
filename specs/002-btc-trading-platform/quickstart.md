# Quick Start Guide: BTC Multi-Strategy Trading Platform

**Feature**: 002-btc-trading-platform  
**Date**: 2025-01-27  
**Purpose**: Get the trading platform up and running quickly

## Prerequisites

- Python 3.14+
- Docker and Docker Compose
- Git
- (Optional) Exchange API keys for live trading (start with paper trading)

## Initial Setup

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd btc-algo-trading
git checkout 002-btc-trading-platform
```

### 2. Environment Setup

Create `.env` file in project root (copy from `.env.example` if available):

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/btc_trading

# Exchange API (for future live trading, not needed for paper trading)
# BINANCE_API_KEY=your_key_here
# BINANCE_API_SECRET=your_secret_here

# Trading Configuration
INITIAL_BALANCE=10000
MAX_DRAWDOWN_THRESHOLD=20.0  # Auto-shutdown at 20% drawdown
WARNING_DRAWDOWN_THRESHOLD=15.0  # Warning at 15% drawdown

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json  # or human for development
```

### 3. Start with Docker Compose

```bash
# Build and start services (app + database)
docker-compose up -d

# Check logs
docker-compose logs -f app
```

This starts:
- PostgreSQL + TimescaleDB database
- Python application container

### 4. Initialize Database

```bash
# Run migrations
docker-compose exec app python -m scripts.migrate

# Or if running locally (outside Docker)
python -m scripts.migrate
```

### 5. Verify Installation

```bash
# Check CLI is working
docker-compose exec app python -m cli.manage --help

# Or locally
python -m cli.manage --help
```

## Running Your First Backtest

### 1. Create a Strategy

```bash
# Create a Trend Following strategy
docker-compose exec app python -m cli.manage create-strategy \
  --name "MyTrendStrategy" \
  --type TREND_FOLLOWING \
  --config '{"lookback_period": 20, "entry_threshold": 0.02}' \
  --risk-limits '{"max_position_size": 1000, "max_drawdown_threshold": 20.0, "warning_drawdown_threshold": 15.0}'
```

### 2. Run Backtest

```bash
# Backtest strategy on historical data
docker-compose exec app python -m cli.backtest \
  --strategy-id <strategy-id-from-step-1> \
  --start-date 2023-01-01 \
  --end-date 2023-12-31 \
  --initial-balance 10000
```

**Expected Output**:
```
Backtest Results:
  Strategy: MyTrendStrategy
  Period: 2023-01-01 to 2023-12-31
  Total Return: +15.3%
  Sharpe Ratio: 1.42
  Max Drawdown: -8.7%
  Win Rate: 52.3%
  Number of Trades: 47
```

### 3. Review Backtest Results

```bash
# List all backtest results
docker-compose exec app python -m cli.manage list-backtests

# View detailed backtest
docker-compose exec app python -m cli.manage view-backtest <backtest-id>
```

## Running Paper Trading

### 1. Start Paper Trading Session

```bash
# Start paper trading with multiple strategies
docker-compose exec app python -m cli.paper_trade start \
  --strategy-ids <strategy-id-1> <strategy-id-2> <strategy-id-3> <strategy-id-4> \
  --initial-balance 10000 \
  --mode PAPER
```

### 2. Monitor Session

```bash
# Check session status
docker-compose exec app python -m cli.paper_trade status <session-id>

# View real-time risk metrics
docker-compose exec app python -m cli.paper_trade metrics <session-id>

# View active positions
docker-compose exec app python -m cli.paper_trade positions <session-id>
```

### 3. Stop Session

```bash
# Stop session and generate performance report
docker-compose exec app python -m cli.paper_trade stop <session-id>
```

**Expected Output**:
```
Session stopped: <session-id>
Performance Report:
  Duration: 24 hours
  Total Return: +2.3%
  Sharpe Ratio: 0.89
  Max Drawdown: -5.2%
  Win Rate: 48.1%
  Number of Trades: 23
  
  Strategy Breakdown:
    - Trend Following: +1.2% (12 trades)
    - Mean Reversion: +0.8% (8 trades)
    - Grid Trading: +0.3% (3 trades)
    - Order Chasing: 0.0% (0 trades)
```

## Managing Strategies

### List Strategies

```bash
docker-compose exec app python -m cli.manage list-strategies
```

### View Strategy Details

```bash
docker-compose exec app python -m cli.manage view-strategy <strategy-id>
```

### Update Strategy Configuration

```bash
docker-compose exec app python -m cli.manage update-strategy <strategy-id> \
  --risk-limits '{"max_position_size": 2000, "max_drawdown_threshold": 25.0}'
```

### Delete Strategy

```bash
docker-compose exec app python -m cli.manage delete-strategy <strategy-id>
```

## Monitoring and Logs

### View Application Logs

```bash
# All logs
docker-compose logs -f app

# Filter by level
docker-compose logs -f app | grep ERROR

# Last 100 lines
docker-compose logs --tail=100 app
```

### Database Access

```bash
# Connect to database
docker-compose exec postgres psql -U user -d btc_trading

# Common queries
# View active sessions
SELECT * FROM trading_sessions WHERE status = 'RUNNING';

# View recent orders
SELECT * FROM orders ORDER BY created_at DESC LIMIT 10;

# View risk metrics
SELECT * FROM risk_metrics ORDER BY timestamp DESC LIMIT 10;
```

## Troubleshooting

### Issue: Docker container fails to start

```bash
# Check Docker logs
docker-compose logs app

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Issue: Database connection errors

```bash
# Check database is running
docker-compose ps postgres

# Check database logs
docker-compose logs postgres

# Verify DATABASE_URL in .env file
```

### Issue: Strategy not generating signals

```bash
# Check strategy logs
docker-compose logs app | grep <strategy-name>

# Verify market data is being received
docker-compose exec app python -m cli.manage check-market-data
```

### Issue: Auto-shutdown triggered

```bash
# View risk metrics history
docker-compose exec app python -m cli.paper_trade metrics <session-id> --history

# Check drawdown threshold settings
docker-compose exec app python -m cli.manage view-strategy <strategy-id>
```

## Next Steps

1. **Backtest Multiple Strategies**: Run backtests on different strategy configurations to find optimal parameters
2. **Paper Trade for 7+ Days**: Follow constitution requirement of 7 days paper trading before live trading
3. **Monitor Performance**: Review metrics and adjust risk limits based on results
4. **Implement Custom Strategies**: Create your own strategy implementations following the strategy interface
5. **Set Up Alerts**: Configure monitoring alerts for drawdown warnings and system errors

## Development Setup (Local, Non-Docker)

If you prefer local development:

```bash
# Create virtual environment
python3.14 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install in development mode
pip install -e .

# Set up local PostgreSQL (or use Docker just for database)
# Update DATABASE_URL in .env

# Run migrations
python -m scripts.migrate

# Run tests
pytest tests/

# Run application
python -m cli.manage --help
```

## Configuration Files

- **`.env`**: Environment variables (gitignored)
- **`config/strategies/`**: Strategy configuration files (YAML/JSON)
- **`data/historical/`**: Historical market data (Parquet files)
- **`docker-compose.yml`**: Docker Compose configuration

## Getting Help

- Check logs: `docker-compose logs -f app`
- Review documentation: `docs/` directory
- Strategy interface: `specs/002-btc-trading-platform/contracts/strategy-interface.md`
- Data model: `specs/002-btc-trading-platform/data-model.md`


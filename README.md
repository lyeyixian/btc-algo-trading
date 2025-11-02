# BTC Multi-Strategy Trading Platform

A medium-frequency algorithmic trading platform for BTC that manages multiple simultaneous trading strategies with comprehensive backtesting, paper trading, risk management, and eventual live trading capabilities.

## Features

- **Multi-Strategy Execution**: Run multiple trading strategies simultaneously (Trend Following, Mean Reversion, Grid Trading, Order Chasing)
- **Backtesting Engine**: Validate strategies on historical data with comprehensive performance metrics
- **Paper Trading**: Test strategies with live market data without risking real capital
- **Risk Management**: Auto-shutdown when drawdown exceeds safe thresholds
- **Live Trading**: Transition validated strategies from paper trading to live trading
- **Performance Metrics**: Sharpe ratio, maximum drawdown, win rate, profit factor, and more

## Architecture

- **Language**: Python 3.14+
- **Database**: PostgreSQL + TimescaleDB (for time-series data and audit trails)
- **Exchange Integration**: ccxt library for flexible exchange support
- **Storage**: Parquet files for historical market data
- **Containerization**: Docker for portability across cloud platforms

## Prerequisites

- Python 3.14 or higher
- Docker and Docker Compose (for database and containerized deployment)
- PostgreSQL 16+ with TimescaleDB extension (if running database locally)
- Git

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd btc-algo-trading
git checkout 002-btc-trading-platform
```

### 2. Setup Environment

Run the setup script to initialize the environment:

```bash
./scripts/setup.sh
```

This script will:
- Create a Python virtual environment
- Install all dependencies
- Create `.env` file from `.env.example`
- Create necessary data directories

### 3. Configure Environment

Edit the `.env` file with your configuration:

```bash
# Database
DATABASE_URL=postgresql+asyncpg://user:password@localhost:5432/btc_trading

# Trading Configuration
INITIAL_BALANCE=10000.0
MAX_DRAWDOWN_THRESHOLD=20.0
WARNING_DRAWDOWN_THRESHOLD=15.0

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json
```

### 4. Start Database (Docker)

```bash
docker-compose -f docker/docker-compose.yml up -d postgres
```

### 5. Run Migrations

```bash
./scripts/migrate.sh
```

### 6. Verify Installation

```bash
source venv/bin/activate
python -m cli.manage --help
```

## Running Your First Backtest

### 1. Create a Strategy

```bash
python -m cli.manage create-strategy \
  --name "MyTrendStrategy" \
  --type TREND_FOLLOWING \
  --config '{"lookback_period": 20, "entry_threshold": 0.02}' \
  --risk-limits '{"max_position_size": 1000, "max_drawdown_threshold": 20.0, "warning_drawdown_threshold": 15.0}'
```

### 2. Run Backtest

```bash
python -m cli.backtest \
  --strategy-id <strategy-id> \
  --start-date 2023-01-01 \
  --end-date 2023-12-31 \
  --initial-balance 10000
```

### 3. Review Results

```bash
python -m cli.manage list-backtests
python -m cli.manage view-backtest <backtest-id>
```

## Running Paper Trading

### Start Paper Trading Session

```bash
python -m cli.paper_trade start \
  --strategy-ids <strategy-id-1> <strategy-id-2> \
  --initial-balance 10000 \
  --mode PAPER
```

### Monitor Session

```bash
# Check status
python -m cli.paper_trade status <session-id>

# View risk metrics
python -m cli.paper_trade metrics <session-id>

# View positions
python -m cli.paper_trade positions <session-id>
```

### Stop Session

```bash
python -m cli.paper_trade stop <session-id>
```

## Development

### Project Structure

```
src/
├── models/              # Domain models
├── strategies/          # Trading strategy implementations
├── services/            # Business logic services
├── exchange/            # Exchange integration layer
├── database/            # Database models and repositories
├── metrics/             # Performance metrics calculation
├── config/              # Configuration management
└── cli/                 # Command-line interface

tests/
├── unit/                # Unit tests
├── integration/         # Integration tests
├── contract/           # Contract tests
└── fixtures/           # Test data and fixtures

docker/                  # Docker configuration
scripts/                 # Utility scripts
data/                    # Data storage (historical data, logs)
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test suite
pytest tests/unit/
pytest tests/integration/
```

### Code Quality

```bash
# Format code
black src/ tests/

# Lint code
ruff check src/ tests/

# Type checking
mypy src/
```

## Docker Deployment

### Build and Run

```bash
# Build Docker image
docker build -f docker/Dockerfile -t btc-trading:latest .

# Run with Docker Compose
docker-compose -f docker/docker-compose.yml up -d
```

### Development with Docker

```bash
# Start services
docker-compose -f docker/docker-compose.yml up -d

# Execute commands in container
docker-compose -f docker/docker-compose.yml exec app python -m cli.manage --help

# View logs
docker-compose -f docker/docker-compose.yml logs -f app
```

## Configuration

### Environment Variables

See `.env.example` for all available configuration options:

- **Database**: `DATABASE_URL`
- **Exchange**: `EXCHANGE_NAME`, `EXCHANGE_SYMBOL`, `EXCHANGE_TESTNET`
- **Trading**: `INITIAL_BALANCE`, `MAX_DRAWDOWN_THRESHOLD`, `WARNING_DRAWDOWN_THRESHOLD`
- **Risk Management**: `RISK_CHECK_INTERVAL`, `AUTO_SHUTDOWN_ENABLED`
- **Logging**: `LOG_LEVEL`, `LOG_FORMAT`

### Strategy Configuration

Strategies are configured via the CLI or configuration files. Each strategy type has specific parameters:

- **Trend Following**: `lookback_period`, `entry_threshold`, `exit_threshold`
- **Mean Reversion**: `lookback_period`, `deviation_threshold`, `entry_level`
- **Grid Trading**: `grid_spacing`, `grid_levels`, `rebalance_interval`
- **Order Chasing**: `momentum_threshold`, `entry_delay`, `max_order_size`

## Risk Management

The platform includes comprehensive risk management:

- **Position Limits**: Maximum position size per strategy
- **Drawdown Monitoring**: Real-time drawdown calculation and thresholds
- **Auto-Shutdown**: Automatic trading halt when drawdown exceeds limits
- **Order Validation**: Pre-execution validation against risk limits
- **Circuit Breakers**: Pause trading on critical errors or anomalies

## Performance Metrics

The platform calculates comprehensive performance metrics:

- **Total Return**: Percentage return over period
- **Sharpe Ratio**: Risk-adjusted return measure
- **Maximum Drawdown**: Largest peak-to-trough decline
- **Win Rate**: Percentage of profitable trades
- **Profit Factor**: Ratio of gross profit to gross loss
- **Number of Trades**: Total trades executed

## Documentation

- **Specification**: `specs/002-btc-trading-platform/spec.md`
- **Data Model**: `specs/002-btc-trading-platform/data-model.md`
- **Implementation Plan**: `specs/002-btc-trading-platform/plan.md`
- **Research**: `specs/002-btc-trading-platform/research.md`
- **Quick Start Guide**: `specs/002-btc-trading-platform/quickstart.md`
- **Strategy Interface**: `specs/002-btc-trading-platform/contracts/strategy-interface.md`

## License

[Add license information]

## Contributing

[Add contributing guidelines]

## Support

[Add support information]


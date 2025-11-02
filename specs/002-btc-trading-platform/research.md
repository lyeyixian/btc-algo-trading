# Research: BTC Multi-Strategy Trading Platform

**Feature**: 002-btc-trading-platform  
**Date**: 2025-01-27  
**Purpose**: Resolve technical unknowns and establish best practices for implementation

## Research Tasks

### Database Selection for Trading System

**Question**: Choose database for audit trails, trading sessions, and performance metrics storage.

**Decision**: PostgreSQL with TimescaleDB extension (hypertables for time-series data)

**Rationale**:
- PostgreSQL provides ACID compliance for critical trading data (audit trails, position tracking)
- TimescaleDB extension optimizes time-series queries (perfect for market data, metrics, audit logs)
- Supports both relational data (sessions, strategies) and time-series data (market data, metrics) efficiently
- Production-ready, widely deployed, excellent Python ecosystem support (SQLAlchemy, asyncpg)
- Docker-friendly, portable across cloud platforms
- Can scale horizontally with TimescaleDB multi-node if needed
- SQLite considered but rejected for production use (concurrent write limitations, not designed for multi-user/time-series)

**Alternatives Considered**:
1. **SQLite**: Simple, file-based, but limited concurrent writes, not optimal for time-series queries
2. **TimescaleDB standalone**: Considered but PostgreSQL+TimescaleDB provides both relational and time-series in one system
3. **InfluxDB**: Great for metrics, but lacks ACID guarantees for critical trading data
4. **MongoDB**: Document-based, but less optimal for time-series queries and audit trail requirements

**Implementation Notes**:
- Use SQLAlchemy for ORM (compatible with asyncpg for async operations)
- Use TimescaleDB hypertables for: market_data, trading_actions, risk_metrics tables
- Regular PostgreSQL tables for: strategies, sessions, backtest_results (less time-series intensive)
- Connection pooling required (SQLAlchemy pool + asyncpg)

---

### Historical Market Data Storage Format

**Question**: How to store and access historical BTC market data for backtesting?

**Decision**: Parquet files with partitioned storage by date range

**Rationale**:
- Parquet is columnar format, efficient for time-series queries and compression
- Fast read performance with pandas (native support)
- Compressed storage (saves disk space for years of data)
- Partitioning by date range enables efficient loading of specific time periods
- Can store OHLCV (Open, High, Low, Close, Volume) data efficiently
- Alternative: CSV files are human-readable but slower and less efficient for large datasets
- Can be stored in S3/GCS/Azure Blob for cloud deployments, or local filesystem

**Alternatives Considered**:
1. **CSV files**: Human-readable but slower, larger file size, less efficient for large datasets
2. **Database storage**: Would require massive tables, slower for bulk backtesting loads
3. **HDF5**: Scientific format but less standard, harder to share/inspect
4. **JSON/JSONL**: Easy to parse but large file size, not optimized for time-series queries

**Implementation Notes**:
- Store in `data/historical/` directory
- File naming: `BTC-USDT_2023-01-01_to_2023-12-31.parquet`
- Use pandas for reading: `pd.read_parquet(path)`
- Partition by year or quarter for large datasets
- Cache frequently accessed data in memory during backtesting

---

### ccxt Library Best Practices for Multi-Exchange Support

**Question**: How to effectively use ccxt for exchange abstraction and ensure proper rate limiting, error handling, and async operations?

**Decision**: Create exchange adapter layer that wraps ccxt with:
- Unified interface for all exchanges
- Async/await support (ccxt.pro or custom async wrapper)
- Rate limiting enforcement per exchange
- Error handling and retry logic
- Connection pooling for WebSocket connections

**Rationale**:
- ccxt provides unified API but requires careful abstraction for production use
- Need async support for concurrent strategy execution (ccxt is synchronous by default)
- Rate limiting varies by exchange, must be enforced to prevent API bans
- Error handling critical for production (network errors, exchange errors, rate limits)
- WebSocket connections need proper management (reconnection, heartbeat)

**Implementation Notes**:
- Create `ExchangeAdapter` base class that wraps ccxt exchange instances
- Implement async wrapper for ccxt synchronous methods
- Use asyncio Semaphore for rate limiting per exchange
- Implement exponential backoff for rate limit errors
- WebSocket connection management with automatic reconnection
- Test against sandbox/testnet environments for each exchange
- Support for both REST API (order placement) and WebSocket (market data streaming)

---

### Docker Architecture for Trading System

**Question**: Docker-centric approach for portability - what's the optimal containerization strategy?

**Decision**: Multi-stage Docker build with:
- Python 3.14+ base image
- Separate containers for: application, database (PostgreSQL+TimescaleDB), optional monitoring
- Docker Compose for local development
- Environment-based configuration (dev, staging, prod)

**Rationale**:
- Multi-stage builds reduce final image size
- Separate containers enable scaling and independent updates
- Docker Compose simplifies local development setup
- Environment variables for configuration (API keys, database URLs) - not baked into images
- Easy deployment to cloud platforms (ECS, Kubernetes, etc.)

**Implementation Notes**:
- Base image: `python:3.14-slim` for smaller image size
- Install dependencies in build stage
- Copy application code in final stage
- Use volumes for: database persistence, historical data (if not using cloud storage)
- Health checks for container monitoring
- Docker Compose includes: app, postgres, optional Redis for caching
- `.env` file for local development (gitignored)
- Cloud deployments use secret management (AWS Secrets Manager, etc.)

---

### Strategy Interface Design Pattern

**Question**: How to design the base strategy interface to ensure all strategies are independently testable and follow common patterns?

**Decision**: Abstract base class with required methods:
- `initialize(config)` - Setup strategy with parameters
- `on_market_data(data)` - Handle incoming market data
- `generate_signals()` - Return buy/sell signals
- `validate_order(order)` - Risk validation before order placement
- `on_order_fill(fill)` - Handle order execution
- `cleanup()` - Cleanup on strategy stop

**Rationale**:
- Ensures consistent interface across all strategy types
- Enables independent testing (mock market data, verify signals)
- Allows strategy isolation (each strategy has its own state)
- Makes it easy to add new strategy types
- Supports strategy composition (one strategy can use another's signals)

**Implementation Notes**:
- Use Python `abc.ABC` for abstract base class
- Type hints required for all methods (constitution compliance)
- Each strategy maintains its own state (positions, indicators, etc.)
- Strategy factory pattern for creating strategy instances from config
- Strategy registry for discovery and loading

---

### Async/Await Patterns for Concurrent Strategy Execution

**Question**: How to execute multiple strategies concurrently without blocking or race conditions?

**Decision**: Use asyncio with:
- Each strategy runs in its own async task
- Shared market data feed distributed to all strategies
- Asyncio locks for shared resources (if any)
- Async queue for order processing
- Event loop management for graceful shutdown

**Rationale**:
- Python asyncio provides efficient concurrency without threading overhead
- Async tasks enable non-blocking strategy execution
- Proper synchronization prevents race conditions in position tracking
- Async queues ensure order processing order is maintained
- Event loop allows graceful shutdown on signals (SIGINT, SIGTERM)

**Implementation Notes**:
- `asyncio.create_task()` for each strategy
- Market data feed publishes to all strategies via async callbacks
- Order executor uses async queue to process orders sequentially per strategy
- Database operations use async SQLAlchemy (asyncpg driver)
- Graceful shutdown: cancel tasks, wait for completion, close connections

---

## Summary

All NEEDS CLARIFICATION items resolved:
1. ✅ Database: PostgreSQL + TimescaleDB
2. ✅ Historical data: Parquet files with date partitioning
3. ✅ Exchange integration: ccxt with custom async adapter layer
4. ✅ Docker architecture: Multi-stage builds, Docker Compose
5. ✅ Strategy interface: Abstract base class pattern
6. ✅ Concurrency: asyncio with tasks and async queues

**Next Steps**: Proceed to Phase 1 design with these decisions in place.


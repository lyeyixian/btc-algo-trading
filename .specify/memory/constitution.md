<!--
  Sync Impact Report:
  Version: 1.0.0 (initial creation)
  Date: 2025-01-27
  Changes:
    - Created initial constitution with Python development best practices
    - Added cryptocurrency algorithmic trading specific principles
    - Added security, risk management, and observability requirements
  Templates Reviewed:
    - plan-template.md: Constitution Check section compatible
    - spec-template.md: No direct references, compatible
    - tasks-template.md: Compatible with principle-driven task types
    - checklist-template.md: Compatible
  Follow-up: None
-->

# BTC Algo Trading Constitution

## Core Principles

### I. Test-First Development (NON-NEGOTIABLE)

**TDD is mandatory for all trading logic**: Tests written → User approved → Tests fail → Then implement. Red-Green-Refactor cycle strictly enforced. Trading strategies MUST have comprehensive unit tests before implementation. All order execution logic MUST be tested in isolation. Backtesting validation is required before any live trading deployment.

**Rationale**: Trading systems handle real money. Bugs can cause catastrophic financial losses. Test-first development ensures correctness and prevents regressions in critical trading logic.

### II. Type Safety & Code Quality

**Python type hints are mandatory**: All functions MUST use type annotations. Use `typing` module or Python 3.9+ built-in generics. Complex data structures MUST use TypedDict or Pydantic models. MyPy or similar type checkers MUST pass with no errors before code review.

**Code quality gates**: Black formatter required. Ruff or Flake8 linting with zero errors. All functions MUST have docstrings following Google or NumPy style. Cyclomatic complexity SHOULD not exceed 10 per function.

**Rationale**: Type safety catches errors at development time. Consistent formatting and documentation enable maintainability and reduce onboarding time.

### III. Error Handling & Observability

**Comprehensive error handling**: All external API calls (exchange APIs, market data) MUST be wrapped in try-except blocks with specific exception types. Network timeouts MUST be explicitly handled. All errors MUST be logged with context (timestamp, request ID, stack trace). Never silently swallow exceptions in trading logic.

**Structured logging**: Use structured logging (e.g., `structlog` or `loguru`) with JSON output. Log levels MUST be appropriate: DEBUG for development, INFO for normal operations, WARNING for recoverable issues, ERROR for failures, CRITICAL for system failures. All trading actions (order placement, fills, cancellations) MUST be logged.

**Metrics & monitoring**: Track latency for order execution, API response times, strategy performance metrics. Use time-series databases or monitoring systems. Alert on anomalies or threshold breaches.

**Rationale**: Trading systems operate in real-time with financial consequences. Observability enables rapid debugging and performance optimization. Proper error handling prevents silent failures that could cause losses.

### IV. Financial Risk Management

**Position limits**: All strategies MUST enforce maximum position size limits. Position limits MUST be configurable and validated before order execution. Hard stops MUST prevent exceeding limits.

**Circuit breakers**: Implement circuit breakers for rapid market movements, API failures, or strategy errors. Trading MUST halt automatically when circuit breakers trigger. Manual override required to resume.

**Order validation**: All orders MUST be validated for: minimum/maximum order size, price sanity checks (within reasonable bounds of current market price), sufficient balance/leverage, exchange-specific constraints.

**Paper trading requirement**: New strategies MUST run in paper/simulation mode for minimum 7 days before live trading. Live trading deployment requires explicit approval and gradual capital allocation.

**Rationale**: Financial risk management prevents catastrophic losses. Circuit breakers protect against runaway strategies. Paper trading validates strategies in realistic conditions without real capital at risk.

### V. Security & API Key Management

**API key security**: API keys MUST NEVER be committed to version control. Use environment variables or secure secret management systems. API keys MUST have minimum required permissions (read-only for market data, restricted trading permissions). Rotate keys periodically.

**Secret management**: Use `.env` files (gitignored) for local development. Use secret management services (AWS Secrets Manager, HashiCorp Vault, etc.) for production. Never hardcode credentials.

**Authentication**: All exchange API calls MUST use signed requests where required. Timestamp validation MUST be enforced to prevent replay attacks. Nonce/request ID tracking for idempotency.

**Rationale**: Compromised API keys can lead to unauthorized trading and financial theft. Proper secret management is essential for production systems.

### VI. Data Integrity & Auditability

**Immutable audit trail**: All trading actions MUST be logged to persistent storage (database or file) with timestamps, order IDs, and before/after state. Logs MUST be append-only and tamper-evident.

**Order idempotency**: All order submissions MUST be idempotent. Use unique client order IDs to prevent duplicate orders from network retries or system restarts.

**Data validation**: Market data MUST be validated for completeness and reasonableness before use in trading decisions. Stale data detection required. Price/volume anomalies MUST trigger alerts.

**Database transactions**: All database writes related to trading state MUST use transactions. Atomic operations required for balance updates and order state changes.

**Rationale**: Audit trails are required for debugging, compliance, and dispute resolution. Idempotency prevents duplicate orders. Data validation prevents trading on bad data.

### VII. Performance & Latency

**Latency optimization**: Order execution paths MUST be optimized for low latency. Avoid blocking I/O in hot paths. Use async/await for concurrent operations. Database queries MUST be indexed and optimized.

**Caching strategy**: Market data SHOULD be cached appropriately. Cache invalidation strategies MUST be defined. Prevent trading on stale cached data.

**Resource limits**: Memory and CPU usage MUST be monitored. Set limits to prevent resource exhaustion. Use connection pooling for database and API clients.

**Rationale**: In algorithmic trading, milliseconds matter. Low latency enables better execution prices. Performance monitoring prevents system degradation during high volatility.

### VIII. Simulation & Backtesting

**Backtesting framework**: All strategies MUST be backtested against historical data before deployment. Backtesting MUST account for: transaction costs, slippage, market impact, order execution delays. Results MUST include: Sharpe ratio, maximum drawdown, win rate, profit factor.

**Paper trading**: Strategies MUST transition through paper trading phase before live trading. Paper trading MUST simulate real exchange conditions including latency and order rejection scenarios.

**Strategy validation**: Backtest results MUST be validated for overfitting. Walk-forward analysis or out-of-sample testing required. Performance metrics MUST be realistic and conservative.

**Rationale**: Backtesting validates strategy logic without risk. Paper trading validates strategy in live market conditions. Proper validation prevents deploying strategies that only worked on historical data by chance.

## Python-Specific Requirements

### Language & Dependencies

**Python version**: Minimum Python 3.11 required. Use modern Python features (pattern matching, type hints, dataclasses). Leverage `asyncio` for concurrent operations.

**Dependency management**: Use `poetry` or `pip-tools` for dependency management. Lock files MUST be committed. `requirements.txt` or `pyproject.toml` MUST specify exact versions for production dependencies. Regular dependency updates with security scanning.

**Virtual environments**: Development MUST use virtual environments. Never install packages globally. Use `venv` or `poetry env`.

### Testing Framework

**Testing stack**: `pytest` for test framework. `pytest-asyncio` for async tests. `pytest-cov` for coverage reporting. Minimum 80% code coverage for trading logic (strategy execution, order management). 100% coverage for critical paths (order validation, risk checks).

**Test organization**: Tests MUST mirror source structure. Unit tests in `tests/unit/`, integration tests in `tests/integration/`, contract tests in `tests/contract/`. Use fixtures for common test data. Mock external API calls in unit tests.

**Test data**: Use fixtures or factories for test data. Never use production API keys in tests. Use testnet/sandbox environments for integration tests.

## Trading System Requirements

### Exchange Integration

**API abstraction**: Exchange-specific code MUST be abstracted behind a common interface. Strategy code MUST NOT depend on exchange-specific implementations. Use adapter pattern for exchange integrations.

**Rate limiting**: All exchange API calls MUST respect rate limits. Implement exponential backoff for rate limit errors. Track API usage and alert on high usage.

**Connection management**: WebSocket connections for real-time data MUST have reconnection logic. Handle network interruptions gracefully. Implement heartbeat/ping mechanisms.

### Strategy Development

**Strategy interface**: All trading strategies MUST implement a common interface with: initialization, market data handlers, signal generation, risk checks, order placement methods. Strategies MUST be independently testable.

**Configuration**: Strategy parameters MUST be configurable via configuration files (YAML, JSON, or environment variables). Sensitive parameters (API keys, secrets) MUST use environment variables or secret management.

**Strategy isolation**: Strategies MUST be isolated from each other. No shared state between strategies. Each strategy MUST manage its own position tracking and order state.

## Development Workflow

### Code Review Requirements

**Pre-merge checks**: All PRs MUST pass: type checking (MyPy), linting (Ruff/Flake8), formatting (Black), unit tests, integration tests (if applicable). CI/CD pipeline MUST enforce these checks.

**Review requirements**: At least one approval required for trading logic changes. Reviewers MUST verify: risk management logic, error handling completeness, test coverage adequacy, performance implications.

**Documentation**: All public APIs, strategy interfaces, and configuration options MUST be documented. Update documentation when adding features or changing behavior.

### Version Control

**Branching strategy**: Use feature branches. Main/master branch MUST always be deployable. Use meaningful commit messages following conventional commits format.

**Release process**: Tag releases with semantic versioning (MAJOR.MINOR.PATCH). Release notes MUST document: new features, breaking changes, bug fixes, migration requirements.

## Governance

This constitution supersedes all other development practices. All PRs and code reviews MUST verify compliance with these principles. Complexity beyond these principles MUST be justified and documented.

Amendments to this constitution require:
1. Documentation of the change and rationale
2. Approval from project maintainers
3. Migration plan if the change affects existing code
4. Version bump (MAJOR for breaking changes, MINOR for additions, PATCH for clarifications)

Use this constitution as the foundation for all development decisions. When in doubt, prioritize safety, testability, and observability.

**Version**: 1.0.0 | **Ratified**: 2025-01-27 | **Last Amended**: 2025-01-27

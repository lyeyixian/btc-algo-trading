# Tasks: BTC Multi-Strategy Trading Platform

**Input**: Design documents from `/specs/002-btc-trading-platform/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/, research.md, quickstart.md

**Tests**: TDD required per Constitution - Tests written → User approved → Tests fail → Then implement

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create project structure per implementation plan in repository root
- [X] T002 Initialize Python 3.14+ project with pyproject.toml and dependencies (ccxt, asyncio, pydantic, structlog, pandas, numpy, sqlalchemy, asyncpg, pytest, pytest-asyncio, pytest-cov, pytest-mock)
- [X] T003 [P] Configure linting and formatting tools (Black, Ruff, MyPy) in pyproject.toml
- [X] T004 [P] Create .env.example template with database URL, API keys placeholders, trading config in repository root
- [X] T005 [P] Create .gitignore file excluding .env, __pycache__, *.pyc, .venv, data/ in repository root
- [X] T006 [P] Create Docker configuration files (Dockerfile, docker-compose.yml, .dockerignore) in docker/ directory
- [X] T007 [P] Create scripts/setup.sh for environment setup in scripts/ directory
- [X] T008 [P] Create scripts/migrate.sh for database migrations in scripts/ directory
- [X] T009 [P] Create README.md with project overview, setup instructions, and quick start guide in repository root

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T010 Setup PostgreSQL + TimescaleDB database schema and migrations framework using SQLAlchemy + Alembic in database/migrations/
- [ ] T011 [P] Create base database models (Base class, common mixins) in database/models.py
- [ ] T012 [P] Create database repositories base class and session management in database/repositories.py
- [ ] T013 [P] Configure error handling and logging infrastructure using structlog in config/logging.py
- [ ] T014 [P] Setup environment configuration management using Pydantic Settings in config/settings.py
- [ ] T015 [P] Create base domain models (common enums, base classes) in models/base.py
- [ ] T016 [P] Create exchange adapter base interface wrapping ccxt in exchange/adapter.py
- [ ] T017 [P] Create market data feed manager base interface in services/market_data.py
- [ ] T018 [P] Create base strategy interface (BaseStrategy abstract class) in strategies/base.py
- [ ] T019 [P] Create metrics calculator base class with interface for Sharpe ratio, drawdown, win rate in metrics/calculator.py
- [ ] T020 [P] Create test fixtures and utilities in tests/fixtures/ directory
- [ ] T021 [P] Configure pytest with fixtures for database, async support, mocking in tests/conftest.py
- [ ] T021A [P] Add performance monitoring and metrics tracking infrastructure (latency, API response times) in services/monitoring.py

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Strategy Backtesting (Priority: P1) 🎯 MVP

**Goal**: Enable backtesting of trading strategies on historical BTC market data to validate performance before live trading

**Independent Test**: Run a backtest with a simple strategy against historical data and verify performance metrics are calculated correctly (profit/loss, Sharpe ratio, maximum drawdown, win rate)

### Tests for User Story 1 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T022 [P] [US1] Unit test for Strategy domain model validation in tests/unit/models/test_strategy.py
- [ ] T023 [P] [US1] Unit test for BacktestResult domain model in tests/unit/models/test_backtest_result.py
- [ ] T024 [P] [US1] Unit test for metrics calculator (Sharpe ratio, drawdown, win rate) in tests/unit/metrics/test_calculator.py
- [ ] T025 [P] [US1] Unit test for historical market data loading from Parquet files in tests/unit/services/test_market_data.py
- [ ] T026 [P] [US1] Integration test for backtesting engine execution in tests/integration/test_backtesting.py
- [ ] T027 [P] [US1] Contract test for strategy interface (BaseStrategy) in tests/contract/test_strategy_interface.py

### Implementation for User Story 1

- [ ] T028 [P] [US1] Create Strategy domain model with type, config, risk_limits, status in models/strategy.py
- [ ] T029 [P] [US1] Create BacktestResult domain model with performance metrics in models/backtest_result.py
- [ ] T030 [P] [US1] Create MarketData domain model for historical data in models/market_data.py
- [ ] T031 [US1] Create Strategy database model (SQLAlchemy ORM) in database/models.py (depends on T011)
- [ ] T032 [US1] Create BacktestResult database model in database/models.py (depends on T011)
- [ ] T033 [US1] Create MarketData database model (TimescaleDB hypertable) in database/models.py (depends on T011)
- [ ] T034 [US1] Implement Strategy repository with CRUD operations in database/repositories.py (depends on T012)
- [ ] T035 [US1] Implement BacktestResult repository in database/repositories.py (depends on T012)
- [ ] T036 [US1] Implement metrics calculator with Sharpe ratio, max drawdown, win rate, profit factor in metrics/calculator.py (depends on T019)
- [ ] T037 [US1] Implement historical market data loader from Parquet files in services/market_data.py (depends on T017)
- [ ] T038 [US1] Implement backtesting engine that executes strategy logic against historical data in services/backtesting.py
- [ ] T039 [US1] Add transaction cost and slippage simulation to backtesting engine in services/backtesting.py (depends on T038)
- [ ] T040 [US1] Implement backtest CLI command in cli/backtest.py
- [ ] T041 [US1] Add error handling and logging for backtest execution in services/backtesting.py
- [ ] T042 [US1] Add validation for strategy configuration before backtest execution in services/backtesting.py
- [ ] T042A [US1] Add historical data gap handling (interpolation, skipping) in services/backtesting.py (depends on T038)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently - can backtest strategies on historical data and view performance metrics

---

## Phase 4: User Story 2 - Paper Trading Execution (Priority: P2)

**Goal**: Execute trading strategies in paper trading mode with live market data to test strategies in real market conditions without risking real capital

**Independent Test**: Start a paper trading session with one strategy, observe that simulated orders are placed based on live market data, and verify order execution simulation works correctly

### Tests for User Story 2 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T043 [P] [US2] Unit test for TradingSession domain model in tests/unit/models/test_trading_session.py
- [ ] T044 [P] [US2] Unit test for Order domain model validation in tests/unit/models/test_order.py
- [ ] T045 [P] [US2] Unit test for Position domain model and calculations in tests/unit/models/test_position.py
- [ ] T046 [P] [US2] Unit test for paper trading order simulator in tests/unit/exchange/test_simulator.py
- [ ] T047 [P] [US2] Integration test for paper trading session execution in tests/integration/test_paper_trading.py
- [ ] T048 [P] [US2] Contract test for live market data feed integration in tests/contract/test_market_data_feed.py

### Implementation for User Story 2

- [ ] T049 [P] [US2] Create TradingSession domain model with mode, status, balance tracking in models/trading_session.py
- [ ] T050 [P] [US2] Create Order domain model with side, type, quantity, price, status in models/order.py
- [ ] T051 [P] [US2] Create Position domain model with quantity, entry price, P&L tracking in models/position.py
- [ ] T052 [US2] Create OrderFill domain model for partial fills tracking in models/order_fill.py
- [ ] T053 [US2] Create TradingSession database model in database/models.py (depends on T011)
- [ ] T054 [US2] Create Order database model with foreign keys in database/models.py (depends on T011)
- [ ] T055 [US2] Create Position database model in database/models.py (depends on T011)
- [ ] T056 [US2] Create OrderFill database model in database/models.py (depends on T011)
- [ ] T057 [US2] Implement TradingSession repository in database/repositories.py (depends on T012)
- [ ] T058 [US2] Implement Order repository in database/repositories.py (depends on T012)
- [ ] T059 [US2] Implement Position repository in database/repositories.py (depends on T012)
- [ ] T060 [US2] Implement live market data feed using ccxt exchange adapter in services/market_data.py (depends on T016, T037)
- [ ] T061 [US2] Implement paper trading order simulator that simulates order execution without sending real orders in exchange/simulator.py
- [ ] T062 [US2] Implement order executor that routes orders to simulator in paper mode in services/order_executor.py
- [ ] T063 [US2] Implement paper trading service that manages session lifecycle and strategy execution in services/paper_trading.py
- [ ] T064 [US2] Add position tracking that updates on order fills in services/paper_trading.py (depends on T063)
- [ ] T065 [US2] Add balance tracking for paper trading session in services/paper_trading.py (depends on T063)
- [ ] T066 [US2] Implement paper trading CLI command (start, status, stop) in cli/paper_trade.py
- [ ] T067 [US2] Add error handling for market data feed failures (pause strategy execution within 30 seconds per SC-007) in services/paper_trading.py
- [ ] T068 [US2] Add order validation (reject orders larger than available balance) in services/order_executor.py
- [ ] T068A [US2] Add partial order fill handling in paper trading simulator in exchange/simulator.py (depends on T061)
- [ ] T068B [US2] Add stale market data detection and alerting in services/market_data.py (depends on T060)
- [ ] T068C [US2] Add comprehensive logging for all trading actions (audit trail) in services/paper_trading.py and services/order_executor.py
- [ ] T068D [US2] Add performance report generation for trading sessions in services/reporting.py (depends on T063)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - can backtest strategies and run paper trading sessions with live market data

---

## Phase 5: User Story 3 - Multi-Strategy Simultaneous Execution (Priority: P3)

**Goal**: Run multiple trading strategies (Trend Following, Mean Reversion, Grid Trading, Order Chasing) simultaneously in paper trading mode to diversify approach and test strategy interactions

**Independent Test**: Start multiple strategies (at least two) in paper trading mode and verify each strategy executes independently with its own position tracking and order management

### Tests for User Story 3 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T069 [P] [US3] Unit test for strategy isolation (no cross-strategy interference) in tests/unit/services/test_strategy_isolation.py
- [ ] T070 [P] [US3] Unit test for concurrent strategy execution in tests/unit/services/test_concurrent_execution.py
- [ ] T071 [P] [US3] Integration test for multi-strategy paper trading session in tests/integration/test_multi_strategy.py
- [ ] T072 [P] [US3] Unit test for Trend Following strategy implementation in tests/unit/strategies/test_trend_following.py
- [ ] T073 [P] [US3] Unit test for Mean Reversion strategy implementation in tests/unit/strategies/test_mean_reversion.py
- [ ] T074 [P] [US3] Unit test for Grid Trading strategy implementation in tests/unit/strategies/test_grid_trading.py
- [ ] T075 [P] [US3] Unit test for Order Chasing strategy implementation in tests/unit/strategies/test_order_chasing.py

### Implementation for User Story 3

- [ ] T076 [P] [US3] Implement Trend Following strategy following BaseStrategy interface in strategies/trend_following.py (depends on T018)
- [ ] T077 [P] [US3] Implement Mean Reversion strategy following BaseStrategy interface in strategies/mean_reversion.py (depends on T018)
- [ ] T078 [P] [US3] Implement Grid Trading strategy following BaseStrategy interface in strategies/grid_trading.py (depends on T018)
- [ ] T079 [P] [US3] Implement Order Chasing strategy following BaseStrategy interface in strategies/order_chasing.py (depends on T018)
- [ ] T080 [US3] Extend paper trading service to support multiple strategies simultaneously using asyncio tasks in services/paper_trading.py (depends on T063)
- [ ] T081 [US3] Ensure strategy isolation (separate position tracking per strategy) in services/paper_trading.py (depends on T080)
- [ ] T082 [US3] Add strategy management (start, stop individual strategies) to paper trading service in services/paper_trading.py (depends on T080)
- [ ] T083 [US3] Add portfolio-level metrics aggregation across all active strategies in services/paper_trading.py (depends on T080)
- [ ] T084 [US3] Update paper trading CLI to support multiple strategy IDs in cli/paper_trade.py (depends on T066)
- [ ] T085 [US3] Add concurrent order processing with asyncio queues to prevent race conditions in services/order_executor.py
- [ ] T086 [US3] Add error isolation (one strategy error doesn't affect others) in services/paper_trading.py (depends on T080)
- [ ] T086A [US3] Add comprehensive logging for multi-strategy trading actions (audit trail) in services/paper_trading.py

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work independently - can run multiple strategies simultaneously in paper trading mode

---

## Phase 6: User Story 4 - Risk Management & Auto-Shutdown (Priority: P4)

**Goal**: Automatically halt trading when drawdown exceeds safe thresholds to prevent catastrophic losses from runaway strategies or adverse market conditions

**Independent Test**: Run a paper trading session, artificially trigger high drawdown conditions, and verify the system automatically halts trading and generates alerts

### Tests for User Story 4 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T087 [P] [US4] Unit test for RiskMetrics domain model in tests/unit/models/test_risk_metrics.py
- [ ] T088 [P] [US4] Unit test for drawdown calculation in tests/unit/metrics/test_drawdown.py
- [ ] T089 [P] [US4] Unit test for risk manager auto-shutdown logic in tests/unit/services/test_risk_manager.py
- [ ] T090 [P] [US4] Integration test for auto-shutdown when drawdown threshold exceeded in tests/integration/test_auto_shutdown.py
- [ ] T091 [P] [US4] Unit test for order cancellation on auto-shutdown in tests/unit/services/test_order_cancellation.py

### Implementation for User Story 4

- [ ] T092 [P] [US4] Create RiskMetrics domain model with drawdown, exposure, leverage tracking in models/risk_metrics.py
- [ ] T093 [US4] Create RiskMetrics database model (TimescaleDB hypertable) in database/models.py (depends on T011)
- [ ] T094 [US4] Implement RiskMetrics repository in database/repositories.py (depends on T012)
- [ ] T095 [US4] Extend metrics calculator to calculate portfolio-level and strategy-level drawdown in metrics/calculator.py (depends on T036)
- [ ] T096 [US4] Implement risk manager service with drawdown monitoring in services/risk_manager.py
- [ ] T097 [US4] Add real-time drawdown monitoring (check thresholds every N seconds) in services/risk_manager.py (depends on T096)
- [ ] T098 [US4] Add auto-shutdown logic when drawdown exceeds threshold in services/risk_manager.py (depends on T096)
- [ ] T099 [US4] Add warning level logging when drawdown approaches threshold in services/risk_manager.py (depends on T096)
- [ ] T100 [US4] Integrate risk manager with paper trading service to monitor sessions in services/paper_trading.py (depends on T080, T096)
- [ ] T101 [US4] Add order cancellation when auto-shutdown is triggered in services/order_executor.py (depends on T062, T096)
- [ ] T102 [US4] Add risk alert generation (which strategies contributed to drawdown) in services/risk_manager.py (depends on T096)
- [ ] T103 [US4] Add manual resume capability after auto-shutdown (requires explicit confirmation) in services/paper_trading.py (depends on T100)
- [ ] T104 [US4] Update paper trading CLI to show risk metrics and handle auto-shutdown in cli/paper_trade.py (depends on T084)
- [ ] T104A [US4] Add comprehensive logging for risk management actions and auto-shutdown events (audit trail) in services/risk_manager.py

**Checkpoint**: At this point, User Stories 1-4 should all work independently - system automatically halts trading when drawdown exceeds thresholds

---

## Phase 7: User Story 5 - Transition to Live Trading (Priority: P5)

**Goal**: Transition validated strategies from paper trading to live trading with real capital to execute profitable strategies with actual funds

**Independent Test**: Configure a strategy for live trading mode, verify all risk controls are enabled, and execute a small test trade

### Tests for User Story 5 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T105 [P] [US5] Unit test for live trading service validation and risk checks in tests/unit/services/test_live_trading.py
- [ ] T106 [P] [US5] Integration test for live trading order execution (with sandbox/testnet) in tests/integration/test_live_trading.py
- [ ] T107 [P] [US5] Contract test for exchange adapter (ccxt wrapper) for live trading in tests/contract/test_exchange_adapter.py

### Implementation for User Story 5

- [ ] T108 [US5] Extend TradingSession to support LIVE mode validation in models/trading_session.py (depends on T049)
- [ ] T109 [US5] Implement exchange adapter wrapper for ccxt with async support and error handling in exchange/adapter.py (depends on T016)
- [ ] T110 [US5] Implement live trading service that enforces risk controls and sends real orders in services/live_trading.py
- [ ] T111 [US5] Add explicit approval requirement before transitioning to live trading in services/live_trading.py (depends on T110)
- [ ] T112 [US5] Add risk management rule enforcement for live trading (position limits, drawdown limits) in services/live_trading.py (depends on T110, T096)
- [ ] T113 [US5] Extend order executor to route to exchange adapter for live orders in services/order_executor.py (depends on T062, T109)
- [ ] T114 [US5] Add auto-shutdown for live trading (halt immediately, cancel pending orders) in services/live_trading.py (depends on T110, T096)
- [ ] T115 [US5] Add live trading CLI command with approval flow in cli/live_trade.py
- [ ] T116 [US5] Add validation to prevent live trading transition if risk controls not configured in services/live_trading.py (depends on T110)
- [ ] T116A [US5] Add comprehensive logging for live trading actions (audit trail) in services/live_trading.py and exchange/adapter.py

**Checkpoint**: At this point, User Stories 1-5 should all work independently - system supports full workflow from backtesting to live trading with risk management

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T117 [P] Add comprehensive error handling for remaining edge cases (API failures, network interruptions) across all services (edge cases already handled in story phases)
- [ ] T120 [P] Add database connection pooling optimization for async operations in database/repositories.py
- [ ] T121 [P] Add market data caching strategy to reduce API calls in services/market_data.py
- [ ] T126 [P] Update documentation with usage examples, API reference, troubleshooting in docs/
- [ ] T127 [P] Run quickstart.md validation and update if needed
- [ ] T128 [P] Add integration tests for full user journeys (backtest → paper trade → view results) in tests/integration/
- [ ] T129 [P] Add database migration scripts for all models in database/migrations/
- [ ] T130 [P] Optimize database queries with proper indexing as per data-model.md in database/migrations/
- [ ] T131 [P] Add Docker health checks and monitoring in docker/Dockerfile
- [ ] T132 [P] Add configuration validation on startup in config/settings.py
- [ ] T133 [P] Integrate performance monitoring with all services (latency tracking, API response times) in services/monitoring.py (depends on T021A)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - User stories can then proceed sequentially in priority order (P1 → P2 → P3 → P4 → P5)
  - US2 depends on US1 completion (uses backtesting for validation)
  - US3 depends on US2 completion (extends paper trading)
  - US4 depends on US3 completion (monitors multi-strategy sessions)
  - US5 depends on US4 completion (requires risk management)
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Depends on US1 completion - Paper trading validates backtested strategies
- **User Story 3 (P3)**: Depends on US2 completion - Multi-strategy extends single-strategy paper trading
- **User Story 4 (P4)**: Depends on US3 completion - Risk management monitors multi-strategy sessions
- **User Story 5 (P5)**: Depends on US4 completion - Live trading requires risk management

### Within Each User Story

- Tests (TDD required) MUST be written and FAIL before implementation
- Models before database models
- Database models before repositories
- Repositories before services
- Services before CLI
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- All test tasks for a user story marked [P] can run in parallel
- All domain model tasks for a user story marked [P] can run in parallel
- All database model tasks for a user story marked [P] can run in parallel
- All strategy implementations (US3) marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
- T022: Unit test for Strategy domain model
- T023: Unit test for BacktestResult domain model
- T024: Unit test for metrics calculator
- T025: Unit test for historical market data loading
- T026: Integration test for backtesting engine
- T027: Contract test for strategy interface

# Launch all domain models for User Story 1 together:
- T028: Create Strategy domain model
- T029: Create BacktestResult domain model
- T030: Create MarketData domain model

# Launch all database models for User Story 1 together:
- T031: Create Strategy database model
- T032: Create BacktestResult database model
- T033: Create MarketData database model
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (9 tasks)
2. Complete Phase 2: Foundational (13 tasks)
3. Complete Phase 3: User Story 1 (22 tasks: 6 tests + 16 implementation)
4. **STOP and VALIDATE**: Test User Story 1 independently - can backtest strategies and view results
5. Deploy/demo if ready

**Total MVP Tasks**: 44 tasks (9 + 13 + 22)

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready (22 tasks: 9 + 13)
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!) (22 tasks: 6 tests + 16 implementation)
3. Add User Story 2 → Test independently → Deploy/Demo (31 tasks: 6 tests + 25 implementation)
4. Add User Story 3 → Test independently → Deploy/Demo (20 tasks: 7 tests + 13 implementation)
5. Add User Story 4 → Test independently → Deploy/Demo (20 tasks: 5 tests + 15 implementation)
6. Add User Story 5 → Test independently → Deploy/Demo (14 tasks: 3 tests + 11 implementation)
7. Add Polish phase → Final optimizations (9 tasks)

**Total Full Implementation**: 138 tasks

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (22 tasks)
2. Once Foundational is done:
   - Developer A: User Story 1 (22 tasks)
   - Developer B: Prepare for User Story 2 (research, design)
3. After US1 complete:
   - Developer A: User Story 2 (26 tasks)
   - Developer B: User Story 3 strategy implementations (parallelizable)
4. Continue sequential delivery of dependent stories

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- TDD required: Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Follow Constitution principles: type hints, error handling, logging, risk management
- All database operations must use transactions
- All exchange API calls must handle rate limits and errors
- All trading actions must be logged for audit trail


# Strategy Interface Contract

**Purpose**: Define the contract that all trading strategies must implement.

## Base Strategy Interface

All trading strategies must inherit from `BaseStrategy` and implement the following methods:

### Methods

#### `initialize(config: StrategyConfig) -> None`

Initialize the strategy with configuration parameters.

**Parameters**:
- `config`: StrategyConfig object containing strategy-specific parameters

**Behavior**:
- Must be called before any other methods
- Should validate configuration parameters
- Should initialize internal state (indicators, positions, etc.)
- Must raise `StrategyConfigError` if configuration is invalid

**Side Effects**: None (pure initialization)

---

#### `on_market_data(data: MarketData) -> None`

Handle incoming market data update.

**Parameters**:
- `data`: MarketData object containing OHLCV data and timestamp

**Behavior**:
- Called whenever new market data arrives
- Strategy should update internal state (indicators, signals)
- Should validate data (check for stale data, anomalies)
- Must not throw exceptions (log errors instead, pause strategy if critical)

**Side Effects**: May update internal state, trigger signal generation

---

#### `generate_signals() -> List[Signal]`

Generate trading signals based on current strategy state.

**Returns**: List of Signal objects (can be empty list)

**Behavior**:
- Called periodically or after market data updates
- Must return list of signals (buy/sell recommendations)
- Signals must include: side (BUY/SELL), quantity, price (optional for market orders)
- Should respect risk limits when generating signals
- Must be idempotent (same state = same signals)

**Side Effects**: None (pure function)

---

#### `validate_order(order: Order) -> bool`

Validate an order before execution.

**Parameters**:
- `order`: Order object to validate

**Returns**: True if order is valid, False otherwise

**Behavior**:
- Must check against risk limits (position size, exposure)
- Must check against strategy-specific constraints
- Should log validation failures with reason
- Called by risk manager before order execution

**Side Effects**: May log validation failures

---

#### `on_order_fill(fill: OrderFill) -> None`

Handle order execution (fill).

**Parameters**:
- `fill`: OrderFill object containing fill details

**Behavior**:
- Called when an order is filled (fully or partially)
- Strategy should update position tracking
- Should update internal state if needed
- Must handle partial fills correctly

**Side Effects**: Updates position tracking, internal state

---

#### `cleanup() -> None`

Cleanup resources when strategy is stopped.

**Behavior**:
- Called when strategy is stopped or session ends
- Should release resources (close connections, save state)
- Must be idempotent (safe to call multiple times)

**Side Effects**: Resource cleanup

---

## Signal Object

```python
@dataclass
class Signal:
    side: OrderSide  # BUY or SELL
    quantity: Decimal
    price: Optional[Decimal]  # None for market orders
    order_type: OrderType  # MARKET or LIMIT
    reason: str  # Human-readable reason for signal
    timestamp: datetime
```

---

## Strategy Configuration

Each strategy type has its own configuration schema:

### Trend Following
- `lookback_period`: int (days)
- `entry_threshold`: float (signal strength)
- `exit_threshold`: float

### Mean Reversion
- `lookback_period`: int
- `deviation_threshold`: float (standard deviations)
- `entry_level`: float

### Grid Trading
- `grid_spacing`: float (price intervals)
- `grid_levels`: int (number of buy/sell levels)
- `rebalance_interval`: int (minutes)

### Order Chasing
- `momentum_threshold`: float
- `entry_delay`: int (seconds)
- `max_order_size`: float

---

## Error Handling

Strategies must handle errors gracefully:

- **Market data errors**: Log warning, skip update, continue running
- **Calculation errors**: Log error, pause strategy, notify risk manager
- **Configuration errors**: Raise StrategyConfigError during initialize()
- **Critical errors**: Log critical error, trigger strategy shutdown

---

## State Management

Strategies must maintain isolated state:
- Position tracking (quantity, average entry price)
- Indicator state (moving averages, etc.)
- Strategy-specific state

State must NOT be shared between strategy instances.

---

## Testing Requirements

All strategies must have:
- Unit tests for signal generation logic
- Unit tests for order validation
- Integration tests with market data simulator
- Mock tests for order fill handling


# Economic Timer Design

Alternative to the instant-fail PvP timer. Trades money for time; lose a life when overtime expires.

## Phases

| Phase | When | Grace Period | Notes |
|-------|------|--------------|-------|
| **BLIND** | Playing non-PvP blinds (small/big) | 60s _or_ `15s × starting_hands` | Resets at end of blind |
| **SHOP** | Shop + blind selection screens | 90s | Resets when selecting a blind |
| **PVP** | Playing PvP blinds (not ahead) | 15s per hand | Only ticks if behind/tied |

## Core Loop

```
[Grace Period] → [Overtime] → Lose Life
       ↑              ↑
       └── action ────┘
```

1. **Grace Period**: Free time. No penalty.
2. **Overtime**: Grace exhausted. Money drains. **30 seconds max** to prevent sandbagging.
3. Overtime expires → **lose a life**.

## Overtime Mechanics

**Duration**: 30 seconds. When it runs out, you lose a life.

**Drain rate**: Money drains while in overtime.
- Base: `ceil(0.04 × dollars)`, minimum $1 (i.e., $1 per $25 you have, rounded up)
- Drains every N seconds (TBD - every 5s? 10s?)

**Ante scaling (TBD)**: Which dimension scales?
- Option A: Drain $2/$3/etc per tick at higher antes
- Option B: Faster tick rate at higher antes
- Option C: Shorter grace periods at higher antes

## State

```lua
MP.GAME.economic_timer = {
    phase = "none",           -- "blind" | "shop" | "pvp" | "none"
    elapsed = 0,              -- seconds in current phase
    overtime_elapsed = 0,     -- seconds in overtime (0-30)
    drain_acc = 0,            -- accumulator for drain ticks
}
```

## Phase Transitions

| Event | Action |
|-------|--------|
| Enter `selecting_hand` (non-PvP) | phase → `blind`, reset elapsed |
| End of blind | Reset `blind` elapsed |
| Enter `shop` or `blind_select` | phase → `shop`, reset elapsed |
| Select a blind | Reset `shop` elapsed, phase → `none` |
| Enter PvP blind (behind/tied) | phase → `pvp` |
| Play a hand (PvP) | Reset `pvp` elapsed |
| Finish round | phase → `none` |

## HUD Display

Replaces the existing PvP timer HUD when economic timer is enabled.

- **Grace**: Remaining grace time (green/white)
- **Overtime**: Remaining overtime (yellow/red), money drain animates via `ease_money`

## Lobby Config

Simple toggle for now:
```lua
economic_timer = true/false
```

Future: presets for grace periods, drain rates, ante scaling.

## Open Questions

1. **Grace period formula**: Fixed 60s or `15s × hands`? Latter creates deck interactions (Grabber = more time, Black Deck = pressure).
2. **Ante scaling**: Which dimension scales? (drain amount, drain rate, grace period)
3. **PvP phase**: Same system with tighter grace, or different rules entirely?
4. **Vagabond**: Triggers at $0 - does this interact with overtime drain?

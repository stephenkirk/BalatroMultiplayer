# Economic Timer Design

Alternative to the instant-fail PvP timer. Trades money for time; lose a life when overtime expires.

## Phases

| Phase | When | Grace Period | Notes |
|-------|------|--------------|-------|
| **BLIND** | Playing non-PvP blinds (small/big) | 60s | Resets at end of blind |
| **SHOP** | Shop + blind selection screens | 90s | Resets when selecting a blind |
| **PVP** | Playing PvP blinds (not ahead) | 15s per hand | Resets after each hand. Only ticks if behind/tied |

## Core Loop

```
[Grace Period] → [Overtime] → Lose Life
       ↑              ↑
       └── action ────┘
```

1. **Grace Period**: Free time. No penalty.
2. **Overtime**: Grace exhausted. Money drains. **30 seconds max** to prevent sandbagging.
3. Overtime expires → **lose a life**.


## Why This Over Instant-Fail Timer

1. **Predictable game length**: Max time per ante/game is calculable (grace + 30s overtime cap)
2. **Player agency**: Time pressure becomes a resource to manage, not a binary fail state
3. **No animation budgeting:** Current timer means mentally reserving time for end of blind / pack animations you haven't triggered yet. Economic timer lets you play the blind, not the clock.
4. **Integrated into economy**: Time is money - literally. Fits Balatro's economic game loop.
5. **Tunable**: If something feels bad, it's a numbers tweak away

## Overtime Mechanics

**Duration**: 30 seconds. When it runs out, you lose a life.

**Drain rate**: Money drains while in overtime.
- Base: `ceil(0.04 × dollars)`, minimum $1 (i.e., $1 per $25 you have, rounded up)
- Drains every N seconds (TBD - every 5s? 10s?)

**Ante scaling (TBD)**: Faster tick rate at higher antes

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

3. **PvP phase**: Same system with tighter grace, or different rules entirely? (15s grace + 30s overtime?)
4. **Vagabond interaction**: Vagabond benefits from <$4. Overtime drain could accidentally buff it. Overtime cap helps, but worth watching.

# Balance Changelog Spec

This document defines the required format for entries in [BALANCE_CHANGELOG.md](BALANCE_CHANGELOG.md).

---

## File Structure

```
# Balance Changelog

[intro paragraph]

---

## [<version>] - <date>

### <Category>

#### <Item Name> — <Change Type>
| Field | Value |
...
```

- Entries are ordered newest-first.
- Each release version gets one `## [version] - date` heading.
- Within a version, group entries under `### <Category>` subheadings (see categories below).

---

## Entry Format

Each individual balance change is a level-4 heading followed by a markdown table:

```markdown
#### <Item Name> — <Change Type>
| Field        | Value |
|--------------|-------|
| **Category** | <category> |
| **Ruleset**  | <ruleset> |
| **Change**   | <what changed, with old → new values> |
| **Rationale**| <why the change was made> |
```

### Required Fields

| Field | Description | Allowed Values |
|-------|-------------|----------------|
| `Category` | Type of game object affected | `Joker`, `Enhancement`, `Consumable`, `Mechanic`, `Economy`, `Tag`, `Blind`, `Booster` |
| `Ruleset` | Which ruleset the object belongs to | `Sandbox`, `Standard`, `All` |
| `Change` | Description of what changed, using `old → new` for numeric diffs | Free text; use backticks for values |
| `Rationale` | Design justification for the change | Free text; be specific about EV, synergies, or player-facing impact |

### Change Types (heading suffix)

| Type | Meaning |
|------|---------|
| `Buff` | Object is stronger (higher stats, lower cost, better odds) |
| `Nerf` | Object is weaker |
| `Rework` | Functionality meaningfully changed (not just a stat tweak) |
| `New` | Object added for the first time |
| `Removed` | Object removed from the pool |
| `Fix` | Bug fix with balance implications |

---

## Category Grouping Order

Within a version block, use this ordering for `###` subheadings:

1. `Jokers`
2. `Enhancements`
3. `Consumables`
4. `Tags`
5. `Blinds`
6. `Boosters`
7. `Economy`
8. `Mechanics`

Omit any category that has no changes in that version.

---

## Version Format

Use the version string exactly as it appears in `Multiplayer.json`, without the `~DEV` suffix in released entries:

- Released: `[0.3.0]`
- Unreleased / in-development: `[Unreleased]`

---

## Example Entry

```markdown
## [0.3.0] - 2026-03-04

### Jokers

#### Golden Ticket — Nerf
| Field | Value |
|-------|-------|
| **Category** | Joker |
| **Ruleset** | Sandbox |
| **Change** | Cost: `5` → `4` |
| **Rationale** | Golden Ticket's expected value at 1-in-2 odds for $5 is weaker than its vanilla counterpart (Ticket, $3 guaranteed). The cost reduction makes it more accessible and compensates for the RNG variance at parity with comparable rarity-2 jokers. |
```

---

## Adding a New Entry

1. Open `BALANCE_CHANGELOG.md`.
2. If the version block for the current release already exists, add your entry under the correct `### Category` subheading (create the subheading if absent, following the ordering above).
3. If no block exists for the current version yet, add a new `## [version] - date` block at the top (below the `---` separator).
4. Fill in all four required fields.
5. Use `old → new` notation for any numeric stat changes.

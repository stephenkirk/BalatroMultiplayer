Add a balance changelog entry for a recent change.

Steps:
1. Read `Multiplayer.json` to get the current version string.
2. Read `BALANCE_CHANGELOG.md` and `BALANCE_CHANGELOG_SPEC.md`.
3. Read the relevant changed file(s) (e.g. the joker/enhancement/consumable Lua file) to understand what was changed. If the user specified a file or item, use that. Otherwise check `git diff HEAD~1` to find recent balance-relevant changes.
4. Write a one-line entry following the spec format:
   `- **<Item>** (<Type>/<Ruleset>) <Change Type> — <what changed>: <one-sentence rationale>`
5. Insert the entry under the matching `## [version]` heading in `BALANCE_CHANGELOG.md`. If no heading exists for the current version, create one with today's date at the top.
6. Show the user the line you added and confirm.

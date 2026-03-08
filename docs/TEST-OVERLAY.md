# Test Overlay

The Test Overlay lets you preview Cursive Raid's UI with fake raid targets — no combat required. Toggle it with `/cursive test` or the checkbox in the General options tab.

## How It Works

### Fake GUIDs

Test targets use a special prefix to distinguish them from real units:

```lua
local TEST_GUID_PREFIX = "CURSIVE_TEST_"
-- Generates: "CURSIVE_TEST_001", "CURSIVE_TEST_002", etc.
```

These GUIDs are injected into `Cursive.core.guids` when the overlay is enabled, and removed when disabled.

### Test Target Data

8 predefined targets with varying properties:
- **Name** — "Raid Boss", "Boss Add", "Elite Add", "Dragon", "Trash Mob", etc.
- **HP / Max HP** — Realistic raid values
- **Raid Icon** — Skull, Cross, Square, etc.
- **Debuffs** — Pre-configured shared debuffs (Sunder, Faerie Fire, Curses, etc.)
- **Own Slots** — How many of the player's class-specific debuffs to inject

### Class-Specific Own Debuffs

The overlay dynamically injects debuffs based on the current player's class:

| Class | Own Debuffs |
|-------|------------|
| Warlock | Curse of Shadow, Curse of Elements, Curse of Recklessness, Curse of Tongues, Curse of Weakness |
| Warrior | Sunder Armor (5 stacks), Demo Shout, Thunder Clap |
| Mage | Winter's Chill (5), Fire Vulnerability (3) |
| Rogue | Expose Armor (4 stacks) |
| Druid | Faerie Fire, Demo Roar |
| Priest | Shadow Weaving (5) |
| Hunter | Faerie Fire |
| Shaman | (none) |

### API Wrapper / Ghost Entries

When the test overlay is active, debuff data is written directly into `curses.sharedDebuffGuids` — the same data structure used by real debuff tracking. This means:

- The UI renders test debuffs exactly as it would real ones
- Debuff order, border colors, missing debuff detection all work normally
- No special rendering code needed

When the overlay is disabled, all `CURSIVE_TEST_*` entries are cleaned from `sharedDebuffGuids` and `Cursive.core.guids`.

### Ghost Entries

Test debuffs use `elapsed` values (time since application) rather than real timestamps. The overlay periodically refreshes these to prevent the UI from showing them as "expired". This creates the illusion of live, ticking debuffs.

## Usage

1. `/cursive test` — Toggle on
2. Adjust your UI: move the frame, change display settings, reorder debuffs
3. `/cursive test` — Toggle off

The overlay works anywhere — in town, in a dungeon, wherever. It's purely client-side fake data.

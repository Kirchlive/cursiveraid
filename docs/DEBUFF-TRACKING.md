# Debuff Tracking — Technical Deep Dive

This document explains how Cursive Raid tracks debuffs across all enemy targets in a raid environment.

## Architecture Overview

```
UNIT_CASTEVENT (SuperWoW)
    │
    ▼
curses.lua ──► sharedDebuffSpellLookup ──► debuff key
    │                                          │
    ▼                                          ▼
playerOwnedCasts[guid][key]              procExpected[guid][key]
    │                                          │
    ▼                                          ▼
ScanTargetForSharedDebuffs(guid) ◄── periodic scan loop
    │
    ▼
sharedDebuffGuids[key][guid] = { stacks, elapsed, duration, ... }
    │
    ▼
UI render (ui.lua)
```

## Shared Debuffs Definition

All trackable raid debuffs are defined in `spells/shared_debuffs.lua` via `getSharedDebuffs()`. Each debuff group has:

- **category** — `"armor"`, `"curse"`, `"shadow"`, `"fire"`, `"frost"`, `"nature"`, etc.
- **class** — Which class applies it
- **raidRelevant** — Whether it shows in raid debuff tracking
- **spells** — Table of spell IDs mapping to `{ name, rank, duration }`

Example:
```lua
sunderarmor = {
    category = "armor",
    class = "warrior",
    raidRelevant = true,
    spells = {
        [7386]  = { name = "Sunder Armor", rank = 1, duration = 30 },
        [11597] = { name = "Sunder Armor", rank = 5, duration = 30 },
        ...
    },
}
```

## Own vs Raid Debuffs

Cursive distinguishes between:

1. **Own debuffs** — Applied by the current player. Tracked via `playerOwnedCasts[targetGuid][debuffKey]` which stores the timestamp of your cast.
2. **Raid debuffs** — Applied by anyone in the raid. Detected via `UNIT_CASTEVENT` or tooltip scanning.

When rendering, own debuffs can be highlighted differently (e.g., brighter border).

## playerOwnedCasts

```lua
curses.playerOwnedCasts[targetGuid][debuffKey] = timestamp
```

Set when `UNIT_CASTEVENT` fires with `casterGuid == playerGuid` and the spell ID maps to a shared debuff key. Used to mark debuffs as "yours" in the UI.

## procExpected — Proc Debuff Detection

Some debuffs are *procs* (not directly cast): Thunderfury, Nightfall, Annihilator, Shadow Vulnerability (from Shadow Weaving). The caster doesn't cast the debuff directly — they cast a trigger spell and the debuff procs.

```lua
curses.procExpected[targetGuid][debuffKey] = timestamp
```

**Flow:**
1. `UNIT_CASTEVENT` fires for a trigger spell (e.g., a melee hit with Thunderfury equipped)
2. Cursive sets `procExpected[targetGuid]["thunderfury"] = GetTime()`
3. On the next `ScanTargetForSharedDebuffs()`, if the debuff is found on the target and `procExpected` timestamp is recent (within ~2s), the proc is confirmed
4. The `procExpected` flag is cleared

This avoids false positives from stale debuff tooltips.

## Armor-Diff Expose Armor Detection

Expose Armor is special because:
- It's applied by rogues who may not be your target
- The debuff tooltip doesn't reliably show in all scan methods
- But the *armor value* of the target changes measurably

### Detection Flow

```
UNIT_CASTEVENT: rogue casts Expose Armor (spell ID known)
    │
    ▼
Capture baseArmor = UnitResistance(targetGuid, 0)  ← SuperWoW GUID API
Set armorMonitor[targetGuid].expectingEA = true
    │
    ▼
Next scan tick (~0.5s later):
    newArmor = UnitResistance(targetGuid, 0)
    armorDiff = baseArmor - newArmor
    │
    ▼
Map armorDiff to combo points:
    CP = armorDiff / exposeArmorPerCP[spellID]
    │
    ▼
Store in sharedDebuffGuids["exposearmor"][targetGuid]
    with stacks = CP, duration from spell data
```

### Why This Works

SuperWoW's `UnitResistance(GUID, 0)` returns the *current* armor of any unit by GUID, not just your target. This means:
- No need to target the mob
- No need to be the rogue
- Pure arithmetic: before armor − after armor = reduction = CP count

### Edge Cases
- If Sunder Armor is applied in the same tick, the diff could be wrong → Cursive debounces with `expectingEA` flag
- If the mob dies mid-detection, `armorMonitor` is cleaned up in `CleanupSharedDebuffs()`

## ScanTargetForSharedDebuffs

The main scan function iterates all known GUIDs and checks:

1. **Tooltip scan** — Reads debuff tooltips for known spell names
2. **procExpected check** — Confirms proc debuffs if the flag is set and recent
3. **Armor diff** — For Expose Armor, checks armor change
4. **Expiry** — Removes debuffs that have exceeded their known duration

Results are stored in `curses.sharedDebuffGuids[debuffKey][targetGuid]`.

## CleanupSharedDebuffs

Periodic cleanup removes:
- Debuffs on GUIDs no longer in `Cursive.core.guids` (unit left combat/died)
- Debuffs past their expected duration
- Stale `procExpected` and `playerOwnedCasts` entries

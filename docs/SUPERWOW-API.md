# SuperWoW API Usage

Cursive Raid depends on [SuperWoW](https://github.com/balakethelock/SuperWoW) for several APIs that don't exist in the vanilla 1.12 client. This document lists every SuperWoW API used and why.

## Required APIs

### `UnitExists(unit)` → name, guid

SuperWoW extends `UnitExists` to return a second value: the unit's GUID (e.g., `"0x0600000000001A3F"`). This is the foundation of all GUID-based tracking.

**Used in:** `core.lua` — to populate `Cursive.core.guids`

### `UnitResistance(unitOrGuid, resistanceIndex)` → value

Returns a unit's resistance value. With SuperWoW, this accepts GUIDs directly, not just unit tokens.

- `resistanceIndex = 0` → Armor

**Used in:** `curses.lua` — Expose Armor detection via armor-diff monitoring. Called as `UnitResistance(targetGuid, 0)` to read armor of any mob by GUID without targeting.

**This is the key API that enables targetless Expose Armor CP detection.**

### `UNIT_CASTEVENT` (Event)

SuperWoW event that fires when any unit casts a spell:

```
UNIT_CASTEVENT(casterGuid, targetGuid, event, spellID, castDuration)
```

- `event` can be `"CAST"`, `"START"`, `"FAIL"`, etc.

**Used in:** `curses.lua` — to detect spell casts from all raid members, set `playerOwnedCasts`, trigger `procExpected` flags, and initiate armor monitoring for Expose Armor.

### `SpellInfo(spellID)` → name, rank, texture

Returns spell metadata for any spell ID.

**Used in:** `curses.lua` — to build `sharedDebuffSpellLookup` mapping spell IDs to debuff keys at initialization.

## How They Work Together

```
1. UNIT_CASTEVENT fires → identifies caster, target, spell
2. SpellInfo(spellID) → maps to debuff key
3. UnitResistance(GUID, 0) → reads armor for EA detection
4. UnitExists(unit) → provides GUIDs for unit tracking
```

## SuperWoW Detection

Cursive checks for SuperWoW at load time:

```lua
if not Cursive.superwow then
    return
end
```

If SuperWoW is not installed, the core module returns early and the addon is effectively disabled. There is no fallback mode.

## Version Compatibility

These APIs have been stable across SuperWoW versions used with TurtleWoW. If a future SuperWoW version changes the `UnitResistance(GUID)` behavior, the Expose Armor detection would need to be updated.

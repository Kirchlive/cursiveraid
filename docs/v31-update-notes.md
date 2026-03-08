# Cursive v3.1 Fork-Update: Fehleranalyse und Korrektionen

> **Quelle:** Claude.ai Konversation vom 27. Dezember 2025
> **Chat-ID:** `c34900cc-cdf4-4585-82b9-21aff771c0c9`
> **Titel:** "Cursive Fork-Update: Fehleranalyse und Korrektionen"

---

## Projektübersicht

- **Fork Repository:** https://github.com/Kirchlive/Cursive
- **Original Repository:** https://github.com/pepopo978/Cursive
- **Plattform:** Turtle WoW (basierend auf Vanilla WoW 1.12 Client)
- **Sprache:** Lua (Vanilla WoW 1.12 kompatibel)

### Erfolgreich implementiert (v3.1)
- ✅ **Dark Harvest Zeitreduktion** wird bei allen DoTs korrekt berechnet (von mehreren Spielern bestätigt)

---

## Identifizierte Bugs

### Bug #1: Eye of Dormant Corruption Trinket (KRITISCH)

**Trinket-Effekt:** "Equip: Increase the duration of Corruption and Shadow Word: Pain by 3 secs."

**Betroffene Klassen & Spells:**
| Klasse | Spell | Base Duration | Mit Trinket |
|--------|-------|---------------|-------------|
| Warlock | Corruption | 18 sek | 21 sek |
| Priest | Shadow Word: Pain | 24 sek | 27 sek |

**Problem:**
- Die +3 Sekunden werden korrekt zur Duration addiert (18 → 21 sek bei Corruption)
- **ABER:** Der DoT verschwindet 3 Sekunden VOR Ablauf (bei 3 sek statt bei 0 sek)
- Mit Platzhalter-Trinket (ohne echte Spielfunktion) funktioniert es korrekt
- Mit echtem Trinket tritt der Fehler auf

**Vermutete Ursache:**
Das Spiel wendet den Trinket-Bonus automatisch an. Cursive erkennt das Trinket und addiert nochmals +3 Sekunden zur ANZEIGE → **doppelte Berechnung**. Der interne Ablauf-Timer basiert auf der tatsächlichen (bereits verlängerten) Spell-Duration, aber Cursive zeigt den DoT noch 3 Sekunden nachdem er im Spiel verschwunden ist.

**Fix-Ansätze:**
- **Option A:** Trinket-Detection entfernen und auf Spiel-Werte vertrauen
- **Option B:** Prüfen ob Trinket-Bonus bereits in der vom Spiel gemeldeten Duration enthalten ist
- **Option C:** Den Ablauf-Zeitpunkt aus dem tatsächlichen UNIT_AURA Event nehmen, nicht berechnen

---

### Bug #2: Fehlerhafte Duration-Reduktion (Rapid Deterioration)

**Problem:** DoT-Durations wurden **HARDCODED** reduziert statt dynamisch berechnet:

| Spell | Base Duration | Falsch hardcoded | Reduktion |
|-------|---------------|------------------|-----------|
| Corruption | 18 sek | 16.92 sek | 6% fest |
| Curse of Agony | 24 sek | 22.56 sek | 6% fest |
| Siphon Life | 30 sek | 28.20 sek | 6% fest |
| Dark Harvest | 8 sek | 7.52 sek | 6% fest |

**Rapid Deterioration Talent (Turtle WoW Custom):**
> "Increases the casting speed of your Affliction spells by 6%. In addition, casting speed increase effects increase the tick speed of your damage over time and channeled Affliction spells with 50/100% efficiency, reducing their duration."

**Korrekte Berechnung:**
- 0 Punkte: 0% Reduktion (Base Duration)
- 1 Punkt: 50% von 6% = **3% Reduktion**
- 2 Punkte: 100% von 6% = **6% Reduktion**

**Fix:** Alle Base-Durations auf Normalwerte zurücksetzen und dynamische Talent-Erkennung implementieren.

**Code-Lösung:**
```lua
-- Rapid Deterioration Talent Detection und Duration-Anpassung
local RAPID_DETERIORATION_TAB = 1 -- Affliction Tree
local RAPID_DETERIORATION_INDEX = X -- Talent-Index (muss im Spiel ermittelt werden)

local function GetRapidDeteriorationReduction()
    local _, _, _, _, points = GetTalentInfo(RAPID_DETERIORATION_TAB, RAPID_DETERIORATION_INDEX)
    if not points or points == 0 then return 0 end
    if points == 1 then return 0.03 end -- 3%
    if points == 2 then return 0.06 end -- 6%
    return 0
end

local AFFLICTION_DOTS = {
    ["Corruption"] = true,
    ["Curse of Agony"] = true,
    ["Siphon Life"] = true,
    ["Dark Harvest"] = true,
}

local function GetAdjustedDuration(baseDuration, spellName)
    if not AFFLICTION_DOTS[spellName] then return baseDuration end
    local reduction = GetRapidDeteriorationReduction()
    return baseDuration * (1 - reduction)
end
```

**Talent-Index ermitteln:**
```lua
/script for i=1,25 do local n,_,_,_,p=GetTalentInfo(1,i);if n then print(i..": "..n.." ("..p..")") end end
```

---

### Bug #3a: Rake - Falsche Bleed-Anzeige bei immunen Mobs

**Problem:**
- Rake zeigt Bleed-DoT auf Mobs die Bleed-immun sind (Elementals, Undead, Geister, Illusionen)
- Nur der initiale Melee-Hit sollte registriert werden, nicht der Bleed

**User-Zitat:**
> "bei elementals oder undeads wie geistern oder illusionen wird trotz bleed immun der dot angezeigt und tickt laut cursive, obwohl halt es eig nicht geht"

**Code-Lösung:**
```lua
local BLEED_IMMUNE_TYPES = {
    ["Elemental"] = true,
    ["Undead"] = true,
    ["Mechanical"] = true,
}

local function CanApplyBleed(unit)
    local creatureType = UnitCreatureType(unit)
    if not creatureType then return true end
    if BLEED_IMMUNE_TYPES[creatureType] then return false end
    return true
end

-- Ergänzend: Combat Log Parsing
local function ParseCombatLogForRakeImmune(combatMessage)
    if string.find(combatMessage, "immune") and string.find(combatMessage, "Rake") then
        return true -- ist immun
    end
    return false
end
```

---

### Bug #3b: Rip - Falsche Duration (ignoriert Combo Points)

**Problem:**
- Rip zeigt immer alte fixe Duration (war 12 sek in Classic Vanilla)
- Turtle WoW hat Rip modifiziert: Duration skaliert mit Combo Points

**Korrekte Rip Duration (Rank 6) — Turtle WoW:**

| Combo Points | Duration | Damage |
|--------------|----------|--------|
| 1 CP | 10 Sekunden | 225 |
| 2 CP | 12 Sekunden | 438 |
| 3 CP | 14 Sekunden | 707 |
| 4 CP | 16 Sekunden | 1032 |
| 5 CP | 18 Sekunden | 1413 |

**Formel:** `Duration = 8 + (ComboPoints * 2)` Sekunden

**Code-Lösung:**
```lua
local RIP_BASE_DURATION = 8
local RIP_DURATION_PER_CP = 2

local function GetRipDuration(comboPoints)
    if not comboPoints or comboPoints < 1 then comboPoints = 1 end
    if comboPoints > 5 then comboPoints = 5 end
    return RIP_BASE_DURATION + (comboPoints * RIP_DURATION_PER_CP)
end

-- Lookup Table Alternative
local RIP_DURATION_BY_CP = {
    [1] = 10, [2] = 12, [3] = 14, [4] = 16, [5] = 18,
}
```

**Wichtig zum Timing:** Combo Points müssen zum ZEITPUNKT DES CASTS erfasst werden (bevor sie verbraucht werden):
```lua
local savedComboPoints = 0

local function OnSpellCastStart(spellName)
    if spellName == "Rip" then
        savedComboPoints = GetComboPoints("player", "target")
    end
end

local function OnSpellCastSuccess(spellName, target)
    if spellName == "Rip" then
        local duration = GetRipDuration(savedComboPoints)
        StartDoTTracker(target, "Rip", duration)
        savedComboPoints = 0
    end
end
```

---

## Implementierungs-Prioritäten

| Priorität | Bug | Beschreibung | Komplexität |
|-----------|-----|--------------|-------------|
| **HOCH** | #2 | Rapid Deterioration hardcoded Werte | Einfach |
| **HOCH** | #1 | Eye of Dormant Corruption Trinket | Mittel-Komplex |
| **MITTEL** | #3b | Rip Combo Point Duration | Einfach |
| **MITTEL** | #3a | Rake Bleed Immunity | Mittel |

## Commit-Strategie
```
git commit -m "fix(warlock): reset hardcoded DoT durations to base values"
git commit -m "feat(warlock): implement dynamic Rapid Deterioration calculation"
git commit -m "fix(druid): implement Rip duration scaling with combo points"
git commit -m "fix(druid): prevent Rake bleed tracking on immune mobs"
git commit -m "fix(trinket): correct Eye of Dormant Corruption duration handling"
git commit -m "feat(testing): add CursiveTestFramework for in-game validation"
```

---

## Test-Framework

Ein umfassendes CursiveTestFramework.lua wurde erstellt mit folgenden Slash-Commands:

| Command | Beschreibung |
|---------|-------------|
| `/cursivetest help` | Alle Tests anzeigen |
| `/cursivetest all` | Alle Tests ausführen |
| `/cursivetest trinket` | Trinket Duration Test |
| `/cursivetest rapid` | Rapid Deterioration Test |
| `/cursivetest rip` | Rip Combo Point Test |
| `/cursivetest rake` | Rake Immunity Test |
| `/cursivetest base` | Base Duration Check |

### Manuelles Test-Protokoll

**Warlock Tests:**
- [ ] Ohne Rapid Deterioration (0/2): Corruption=18, CoA=24, SL=30, DH=8
- [ ] Mit 1/2 Punkten: Corruption≈17.46, CoA≈23.28, SL≈29.10, DH≈7.76
- [ ] Mit 2/2 Punkten: Corruption≈16.92, CoA≈22.56, SL≈28.20, DH≈7.52

**Druid Tests:**
- [ ] Rip: 1CP=10s, 2CP=12s, 3CP=14s, 4CP=16s, 5CP=18s
- [ ] Rake auf normalem Mob: Bleed wird getrackt
- [ ] Rake auf Elemental/Undead: Kein Bleed-Tracking

**Trinket Tests (wenn verfügbar):**
- [ ] Corruption mit Trinket: 21 sek, läuft bis 0
- [ ] SWP mit Trinket: 27 sek, läuft bis 0

---

## Vanilla WoW 1.12 LUA Einschränkungen
- Kein `table.wipe()` — verwende `for k in pairs(t) do t[k] = nil end`
- Kein `string.format()` mit `%q`
- Begrenzte API-Funktionen
- Events/Payloads unterscheiden sich von Retail
- `GetComboPoints(unit, target)` ist verfügbar
- `UnitCreatureType(unit)` ist verfügbar
- `GetTalentInfo(tab, index)` ist verfügbar

## Turtle WoW Besonderheiten
- Custom Talents (Rapid Deterioration, Dark Harvest)
- Modifizierte Spell-Mechaniken (Rip mit CP-Scaling)
- Zusätzliche Items mit Custom-Effekten (Eye of Dormant Corruption)

## Nützliche Debug-Befehle
```lua
-- Talent-Info auslesen
/script for i=1,25 do local n,_,_,_,p=GetTalentInfo(1,i);if n then print(i..": "..n.." ("..p..")") end end

-- Creature Type des Targets
/script print("Type: "..(UnitCreatureType("target") or "nil"))

-- Aktuelle Combo Points
/script print("CP: "..GetComboPoints("player","target"))

-- Debuffs auf Target auflisten
/script for i=1,16 do local n=UnitDebuff("target",i);if n then print(i..": "..n) end end

-- Equipped Trinkets prüfen (Slot 13 & 14)
/script print(GetInventoryItemLink("player",13))
/script print(GetInventoryItemLink("player",14))
```

---

## Referenzen
- [Turtle WoW Wiki](https://turtle-wow.fandom.com/)
- [Vanilla WoW API](https://wowwiki-archive.fandom.com/wiki/World_of_Warcraft_API)
- [Original Cursive (pepopo978)](https://github.com/pepopo978/Cursive)
- [Fork Cursive (Kirchlive)](https://github.com/Kirchlive/Cursive)

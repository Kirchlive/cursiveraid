# Cursive v3.2 — Shared Debuffs Spezifikation

> **Stand:** 7. Februar 2026
> **Quelle:** Robs Claude.ai-Konversationen + manuelle Zusammenstellung
> **Status:** Komplett — bereit zur Implementierung

---

## Übersicht

v3.2 erweitert das bestehende Faerie Fire Shared Debuff System um **alle raid-relevanten Debuffs** aller Klassen. Das bestehende Pattern (UNIT_CASTEVENT + sharedDebuffs-Tabelle) wird beibehalten und skaliert.

---

## Implementierungs-Architektur

### Bestehendes Pattern (v3.1)
```lua
-- cursive.lua Zeile 36-41
sharedDebuffs = { faeriefire = {} }
sharedDebuffGuids = { faeriefire = {} }

-- Event Handler Zeile 383-394
UNIT_CASTEVENT → prüft spellID → setzt GetTime() in sharedDebuffGuids
```

### Neues Pattern (v3.2)
- Gleiche Struktur, aber iteriert über ALLE debuffKeys
- Neue Felder: `stacks` (max stacks), optionale Kategorisierung
- Settings-Panel für jeden Debuff toggle-bar

---

## ⚠️ Spell-ID Diskrepanzen

Beim Abgleich der verschiedenen Quellen gibt es Abweichungen. **Die letzte Tabelle (Robs finale Zusammenstellung) gilt als Referenz**, Abweichungen dokumentiert:

| Debuff | Erste Liste | Finale Liste | Anmerkung |
|--------|-------------|--------------|-----------|
| Shadow Vulnerability | 17794-17798 | 17793, 17796, 177801-177803 | **177801+ sind Tippfehler** → vermutlich 17800, 17801, 17803 |
| Freezing Trap | 3355, 14308, 14309 | 1499, 14310, 14311 | Unterschiedliche IDs — 1499 ist Freezing Trap Effect |
| Winter's Chill | 12579 | 11180, 28592-28595 | Finale hat mehr Ranks |
| Fire Vulnerability | 22959 | 22959-22964 | Finale hat alle Ranks |
| Shadow Weaving | 15258 | 15257, 15331-15334 | Finale hat alle Ranks |
| Expose Armor Stacks | 1 (scales CP) | 5 | Finale sagt 5 Stacks |

**→ Müssen vor Implementation mit TurtleWoW DB verifiziert werden!**

---

## Vollständige Debuff-Tabellen (Finale Referenz)

### DRUID

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Faerie Fire | 1 | 40s | 770, 778, 9749, 9907 | ✅ Bereits implementiert |
| Faerie Fire (Feral) | 1 | 40s | 16857, 17390, 17391, 17392 | ✅ Bereits implementiert |
| Faerie Fire (Bear) | 1 | 40s | 16855, 17387, 17388, 17389 | ✅ Bereits implementiert |
| Demoralizing Roar | 1 | 30s | 99, 1735, 9490, 9747, 9898 | -AP |
| Hibernate | 1 | 20/30/40s | 2637, 18657, 18658 | CC: Beasts, Dragonkin |

### HUNTER

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Hunter's Mark | 1 | 120s | 1130, 14323, 14324, 14325 | +RAP |
| Freezing Trap | 1 | 10/15/20s | 1499, 14310, 14311 | CC |
| Wyvern Sting | 1 | 12s | 19386, 24132, 24133 | CC: Sleep |
| Scatter Shot | 1 | 4s | 19503 | Disorient |

### MAGE

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Winter's Chill | X | 15s | 11180, 28592, 28593, 28594, 28595 | +Frost Crit/Stack |
| Fire Vulnerability | X | 30s | 22959, 22960, 22961, 22962, 22963, 22964 | +Fire Dmg/Stack |
| Ignite | 1 | 4s | 12654 | DoT nach Fire Crit |
| Polymorph | 1 | 20/30/40/50s | 118, 12824, 12825, 12826 | CC |
| Polymorph: Pig | 1 | 50s | 28272 | → als Polymorph |
| Polymorph: Turtle | 1 | 50s | 28271 | → als Polymorph |
| Polymorph: Rodent | 1 | 50s | 57560 | → als Polymorph |

### PALADIN

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Judgement of Light | 5 | 10s | 20185, 20344, 20345, 20346 | Heal on Hit |
| Judgement of Wisdom | 5 | 10s | 20186, 20354, 20355 | Mana on Hit |
| Judgement of the Crusader | 5 | 10s | 21183, 20188, 20300, 20301, 20302, 20303 | Holy Dmg |
| Hammer of Justice | 1 | 3/4/5/6s | 853, 5588, 5589, 10308 | CC: non-elite |

### PRIEST

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Shadow Weaving | X | 15s | 15257, 15331, 15332, 15333, 15334 | +Shadow Dmg/Stack |
| Shackle Undead | 1 | 30/40/50s | 9484, 9485, 10955 | CC: Undead |
| Mind Control | 1 | Channel | 605, 10911, 10912 | CC: Humanoids |
| Psychic Scream | 1 | 8s | 8122, 8124, 10888 | AoE Fear |

### ROGUE

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Expose Armor | 5 | 30s | 8647, 8649, 8650, 11197, 11198 | -Armor (CP as stacks) |
| Wound Poison | 5 | 15s | 13218, 13222, 13223, 13224, 13225 | -Healing/Stack |
| Sap | 1 | 25/35/45s | 6770, 2070, 11297 | CC: Humanoids |

### WARLOCK — Curses

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Curse of Recklessness | 1 | 120s | 704, 7658, 7659, 11717 | -Armor |
| Curse of the Elements | 1 | 300s | 1490, 11721, 11722 | +Fire/Frost Dmg |
| Curse of Shadow | 1 | 300s | 17862, 17937 | +Shadow/Arcane Dmg |
| Curse of Tongues | 1 | 30s | 1714, 11719 | +Cast Time |
| Curse of Weakness | 1 | 120s | 702, 1108, 6205, 7646, 11707, 11708 | -Attack Speed |
| Shadow Vulnerability | 1 | 10s | 17793, 17796, 17800, 17801, 17803 | +Shadow Dmg (IDs verifizieren!) |

### WARLOCK — CC

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Banish | 1 | 20/30s | 710, 18647 | CC: Demons, Elementals |
| Enslave Demon | 1 | 300s | 1098, 11725, 11726 | Control Demon |
| Fear | 1 | 10/15/20s | 5782, 6213, 6215 | Fear |
| Howl of Terror | 1 | 10/15s | 5484, 17928 | AoE Fear |
| Seduction | 1 | 15s | 6358 | CC: Humanoids |

### WARRIOR

| Debuff | Stacks | Duration | Spell IDs | Note |
|--------|--------|----------|-----------|------|
| Sunder Armor | 5 | 30s | 7386, 7405, 8380, 11596, 11597 | -Armor/Stack |
| Demoralizing Shout | 1 | 30s | 1160, 6190, 11554, 11555, 11556 | -AP |
| Thunder Clap | 1 | 30s | 6343, 8198, 8204, 8205, 11580, 11581 | -Attack Speed |
| Mortal Strike | 1 | 10s | 12294, 21551, 21552, 21553 | -50% Healing |
| Intimidating Shout | 1 | 8s | 5246 | AoE Fear |

### WEAPON PROCS / ITEMS

| Debuff | Source | Stacks | Duration | Spell IDs | Note |
|--------|--------|--------|----------|-----------|------|
| Armor Shatter | Annihilator | 3 | 45s | 16928 | -200 Armor/Stack |
| Spell Vulnerability | Nightfall | 1 | 7s | 23605 | +10% Spell Dmg |
| Gift of Arthas | Consumable | 1 | 180s | 11374 | +8 Shadow Dmg |
| Thunderfury | Legendary | 1 | 12s | 21992 | -Nature Resist |

---

## Kategorien (für UI-Gruppierung)

### Raid DPS — Damage Vulnerability
- **Fire:** Fire Vulnerability (Mage), Curse of the Elements (Warlock)
- **Frost:** Curse of the Elements (Warlock), Winter's Chill (Mage)
- **Shadow:** Curse of Shadow (Warlock), Shadow Weaving (Priest), Shadow Vulnerability (Warlock)
- **Arcane:** Curse of Shadow (Warlock)
- **Holy:** Judgement of the Crusader (Paladin)
- **All Spell:** Nightfall / Spell Vulnerability (Weapon Proc)

### Armor Reduction (Physical DPS)
- Sunder Armor (Warrior) — 5 Stacks
- Expose Armor (Rogue) — **Mutually exclusive mit Sunder**
- Faerie Fire (Druid)
- Curse of Recklessness (Warlock)
- Annihilator (Weapon Proc) — 3 Stacks

### Tank Mitigation
- Demoralizing Shout (Warrior)
- Demoralizing Roar (Druid)
- Thunder Clap (Warrior)

### Healing Reduction
- Mortal Strike (Warrior)
- Wound Poison (Rogue)

### Crowd Control
- Polymorph (Mage) — Humanoids, Beasts, Critters
- Banish (Warlock) — Demons, Elementals
- Shackle Undead (Priest) — Undead
- Hibernate (Druid) — Beasts, Dragonkin
- Freezing Trap (Hunter) — Any
- Fear / Howl of Terror (Warlock)
- Sap (Rogue) — Humanoids (OOC)
- Seduction (Warlock) — Humanoids
- Intimidating Shout (Warrior)
- Psychic Scream (Priest)
- Hammer of Justice (Paladin)

### Utility
- Hunter's Mark (Hunter) — +RAP
- Judgement of Light (Paladin) — Heal on Hit
- Judgement of Wisdom (Paladin) — Mana on Hit

---

## Implementierungs-Checkliste

- [ ] Spell IDs verifizieren (Shadow Vulnerability, Freezing Trap, Winter's Chill)
- [ ] `spells/shared_debuffs.lua` erweitern
- [ ] `cursive.lua` — sharedDebuffs/sharedDebuffGuids Strukturen
- [ ] `cursive.lua` — Event Handler generisch machen (iterate alle debuffKeys)
- [ ] `cursive.lua` — Spell Name Handling erweitern
- [ ] `settings.lua` — Options Panel für neue Debuffs
- [ ] `Localization.lua` — Alle neuen Debuff-Namen
- [ ] `CursiveTestFramework.lua` — Test Commands
- [ ] Dokumentation/README aktualisieren
- [ ] Stack-Tracking implementieren (Sunder, Expose, Shadow Weaving etc.)
- [ ] Mutual Exclusion: Sunder vs Expose Armor

---

*Generiert aus Robs Claude.ai Konversationen und manueller Zusammenstellung*

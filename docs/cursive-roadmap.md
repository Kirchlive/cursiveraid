# Cursive Addon — Feature Roadmap & Zusammenfassung

> **Stand:** 7. Februar 2026
> **Fork:** https://github.com/Kirchlive/Cursive
> **Original:** https://github.com/pepopo978/Cursive
> **Plattform:** Turtle WoW (Vanilla WoW 1.12)

---

## Was ist Cursive?

Cursive ist ein **DoT-Tracking Addon** für Turtle WoW. Der Kirchlive-Fork erweitert das Original von pepopo978 um korrekte Berechnungen für Turtle WoW's Custom-Content (Talents, Items, modifizierte Spell-Mechaniken).

---

## Version History

### ✅ v3.0 — Initial Fork (vor Dez 2025)
- Fork des Original-Addons
- **Dark Harvest Zeitreduktion** für alle DoTs korrekt implementiert
- Von mehreren Spielern getestet und bestätigt
- Generell guter Anklang in der Community

### 🔧 v3.1 — Bugfixes & Korrektionen (27. Dez 2025)

**Status:** Geplant / In Arbeit

| # | Bug | Status | Priorität |
|---|-----|--------|-----------|
| 1 | Eye of Dormant Corruption: DoT verschwindet 3s zu früh (doppelte Duration-Berechnung) | 🔧 Analyse | HOCH |
| 2 | Rapid Deterioration: Hardcoded Duration-Reduktion statt dynamisch | 🔧 Fix bereit | HOCH |
| 3a | Rake: Bleed-DoT auf immunen Mobs (Elemental, Undead) | 🔧 Fix bereit | MITTEL |
| 3b | Rip: Ignoriert Combo Points, zeigt alte fixe 12s Duration | 🔧 Fix bereit | MITTEL |

**Entscheidungen:**
- Base-Durations werden auf Normalwerte zurückgesetzt (Corruption=18s, CoA=24s, SL=30s, DH=8s)
- Rapid Deterioration wird dynamisch berechnet (0/1/2 Talentpunkte → 0%/3%/6%)
- Rip-Formel: `Duration = 8 + (CP * 2)` (10-18 Sekunden)
- Bleed-Immunity-Check über `UnitCreatureType()` + Combat Log Parsing
- Combo Points werden zum Zeitpunkt des Casts gespeichert (bevor sie verbraucht werden)
- Test-Framework (`/cursivetest`) für In-Game-Validierung

### 🚀 v3.2 — Shared Debuffs & Raid Support (Jan 2026)

**Status:** In Entwicklung

| Feature | Beschreibung | Status |
|---------|-------------|--------|
| Shared Debuffs System | DoT-Daten zwischen Raid-Mitgliedern teilen | 📋 Geplant |
| Raid Debuff Tracking | Alle aktiven Debuffs auf Targets für den ganzen Raid sichtbar | 📋 Geplant |
| Debuff Slot Management | Warnung bei 16-Debuff-Limit Überschreitung | 📋 Geplant |
| Addon-Kommunikation | SendAddonMessage-basierte Synchronisation | 📋 Geplant |

**Technische Basis:**
- `SendAddonMessage("CURSIVE", data, "RAID")` für Inter-Client-Kommunikation
- CHAT_MSG_ADDON Event-Handler für Empfang
- Timer-Synchronisation zwischen Clients

---

## Geplante Features (Gesamtübersicht)

### Warlock
- [x] Dark Harvest Zeitreduktion für alle DoTs
- [ ] Dynamische Rapid Deterioration Berechnung (0/3/6%)
- [ ] Eye of Dormant Corruption Fix (keine doppelte Duration)
- [ ] Korrekte Base-Durations (Corruption=18, CoA=24, SL=30, DH=8)

### Priest
- [ ] Eye of Dormant Corruption Fix für Shadow Word: Pain
- [ ] Shared Debuff-Tracking für Raid-Priester

### Druid
- [ ] Rip Duration mit Combo Point Scaling (8 + CP*2)
- [ ] Rake Bleed-Immunity-Check (Elemental, Undead, Mechanical)

### Raid/Shared
- [ ] Addon-zu-Addon Kommunikation (CURSIVE Prefix)
- [ ] Shared DoT-Timer-Anzeige
- [ ] 16-Debuff-Limit-Warnung
- [ ] Debuff-Priorität-Hierarchie

### Qualität & Testing
- [ ] CursiveTestFramework.lua mit `/cursivetest` Command
- [ ] Automatisierte Duration-Validierung
- [ ] Trinket-Simulation für Tests ohne physisches Item

---

## Bekannte Einschränkungen

### Vanilla WoW 1.12 API Limitierungen
- Kein `table.wipe()` 
- Begrenzte API-Funktionen vs. Retail
- 16 Debuff-Limit auf Targets
- Events/Payloads unterscheiden sich von moderneren WoW-Versionen
- `UnitCreatureType()` gibt nicht immer korrekte Werte für custom Mobs

### Turtle WoW Spezifika
- Custom Talents (Rapid Deterioration, Dark Harvest) erfordern manuelle Talent-Tree-Indizes
- Modifizierte Spell-Mechaniken (Rip CP-Scaling) weichen von Classic Vanilla ab
- Custom Items (Eye of Dormant Corruption) mit Sonder-Effekten
- Einige Spell-Durations unterscheiden sich vom Original

### Testbarkeit
- Nicht alle Features direkt testbar (kein Priest-Charakter, kein Trinket)
- Test-Framework mit Simulations-Modus erforderlich
- PFUI-Addon hat ähnliche Duration-Anzeigeprobleme (lt. User)

---

## Community Feedback

> "Unser Update hat grundsätzlich sehr guten Anklang gefunden."

**Positive Rückmeldungen:**
- Dark Harvest Berechnung funktioniert einwandfrei
- Allgemeines Lob für Fork-Verbesserungen

**Kritische Anmerkungen:**
- Trinket-Bug betrifft Endgame-Spieler (Eye of Dormant Corruption)
- Duration-Fehler durch hardcoded Rapid Deterioration Werte
- Druiden-Spieler melden falsche Rake/Rip Werte
- PFUI-Addon hat gleiche Probleme → Community-weit bekanntes Issue

---

## Datenquellen

| Dokument | Quelle | Vollständig? |
|----------|--------|-------------|
| [v3.1 Update Notes](v31-update-notes.md) | Chat `c34900cc...` (27. Dez 2025) | ✅ Vollständig |
| [v3.2 Shared Debuffs](v32-shared-debuffs.md) | Chat `680588f8...` (17. Jan 2026) | ⚠️ Teilweise (Browser Relay verloren) |
| [v3.2 Shared Debuffs](v32-shared-debuffs.md) | Chat `e6681705...` (6. Jan 2026) | ⚠️ Teilweise (Browser Relay verloren) |

---

*Letzte Aktualisierung: 7. Februar 2026*

-- defaultProfiles.lua — Built-in Default Profiles for Cursive Raid
-- Loaded once on first run (no saved profiles exist yet).
-- Each profile is a PARTIAL table — only keys that differ from RegisterDefaults.
-- Missing keys will use the addon defaults automatically.
-- Lua 5.0 compatible.

-- ============================================================
-- Default profile definitions
-- ============================================================
local CursiveDefaultProfiles = {}

-- ============================================================
-- 1. RAID LEADER — Full raid intelligence overview
-- ============================================================
CursiveDefaultProfiles["Raid Leader"] = {
    -- Large display: see everything at once
    maxcurses = 10,
    maxrow = 15,
    maxcol = 1,
    height = 18,
    healthwidth = 110,
    curseiconsize = 18,
    raidiconsize = 18,
    scale = 1.0,
    spacing = 3,
    -- Show all UI elements
    showtitle = true,
    showtargetindicator = true,
    showraidicons = true,
    showhealthbar = true,
    showunitname = true,
    alwaysshowcurrenttarget = true,
    showMissingDebuffs = true,
    -- Armor tracking on
    armorStatusEnabled = true,
    armorColorIndicator = true,
    armorDisplayStructure = "live+removed",
    -- Debuff order: Raid debuffs front, own class in back
    orderfront = "otherraid",
    ordermiddle = "ownraid",
    orderback = "otherclass",
    orderlast = "ownclass",
    orderotherside = "none",
    -- Enable ALL raid debuffs (RL needs to see everything)
    shareddebuffs = {
        sunderarmor = true, exposearmor = true, faeriefire = true, curseofrecklessness = true,
        firevulnerability = true, winterschill = true, shadowvulnerability = true, shadowweaving = true,
        curseoftheelements = true, curseofshadow = true,
        armorshatter = true, spellvulnerability = true, thunderfury = true, puncturearmor = true,
        demoshout = true, demoroar = true, thunderclap = true, mortalstrike = true,
        huntersmark = true, woundpoison = true, giftofarthas = true,
    },
    -- Colored borders for quick identification
    borderownclass = "green",
    borderotherclass = "classcolor",
    borderownraid = "green",
    borderotherraid = "classcolor",
    borderwidth = 2,
    borderopacity = 85,
    -- Timer styling
    coloreddecimalduration = true,
    durationtimercolor = "classcolor",
    -- Filters: show hostiles in combat
    filterincombat = true,
    filterhostile = true,
    filterattackable = true,
}

-- ============================================================
-- 2. WARLOCK — Curse management focus
-- ============================================================
CursiveDefaultProfiles["Warlock"] = {
    maxcurses = 8,
    maxrow = 10,
    height = 16,
    healthwidth = 90,
    curseiconsize = 18,
    -- Own curses front and center
    orderfront = "ownclass",
    ordermiddle = "ownraid",
    orderback = "otherraid",
    orderlast = "otherclass",
    orderotherside = "none",
    -- Warlock-relevant debuffs
    shareddebuffs = {
        curseofrecklessness = true, curseoftheelements = true, curseofshadow = true,
        curseoftongues = true, curseofweakness = true,
        shadowvulnerability = true, shadowweaving = true,
        banish = true, fear = true, howlofterror = true, enslavedemon = true, seduction = true,
        sunderarmor = true, faeriefire = true,
    },
    -- Green border on own, off for others
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "green",
    borderotherraid = "off",
    borderwidth = 2,
    coloreddecimalduration = true,
    armorStatusEnabled = true,
    armorDisplayStructure = "live+removed",
}

-- ============================================================
-- 3. WARRIOR TANK — Sunder tracking & survivability
-- ============================================================
CursiveDefaultProfiles["Warrior Tank"] = {
    maxcurses = 8,
    maxrow = 8,
    height = 18,
    healthwidth = 100,
    curseiconsize = 20,
    raidiconsize = 20,
    scale = 1.1,
    -- Own class first (Sunder!), then raid debuffs
    orderfront = "ownclass",
    ordermiddle = "ownraid",
    orderback = "otherraid",
    orderlast = "otherclass",
    orderotherside = "none",
    -- Tank-relevant debuffs
    shareddebuffs = {
        sunderarmor = true, exposearmor = true, faeriefire = true, curseofrecklessness = true,
        demoshout = true, thunderclap = true, mortalstrike = true, intimidatingshout = true,
        armorshatter = true, puncturearmor = true, thunderfury = true,
        demoroar = true, huntersmark = true,
    },
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "green",
    borderotherraid = "classcolor",
    borderwidth = 3,
    coloreddecimalduration = true,
    -- Armor tracking crucial for tanks
    armorStatusEnabled = true,
    armorColorIndicator = true,
    armorDisplayStructure = "live+removed",
    armorTextSize = 12,
    filterincombat = true,
    filterhostile = true,
}

-- ============================================================
-- 4. MAGE — Fire/Frost vulnerability + CC
-- ============================================================
CursiveDefaultProfiles["Mage"] = {
    maxcurses = 6,
    maxrow = 10,
    height = 16,
    curseiconsize = 16,
    orderfront = "ownclass",
    ordermiddle = "ownraid",
    orderback = "otherraid",
    orderlast = "otherclass",
    shareddebuffs = {
        firevulnerability = true, winterschill = true, ignite = true, polymorph = true,
        curseoftheelements = true, curseofshadow = true,
        sunderarmor = true, faeriefire = true,
        spellvulnerability = true,
    },
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "off",
    borderotherraid = "off",
    coloreddecimalduration = true,
    armorStatusEnabled = false,
}

-- ============================================================
-- 5. HEALER — Minimal clutter, debuff awareness
-- ============================================================
CursiveDefaultProfiles["Healer"] = {
    maxcurses = 5,
    maxrow = 8,
    maxcol = 1,
    height = 14,
    healthwidth = 80,
    curseiconsize = 14,
    raidiconsize = 14,
    scale = 0.9,
    spacing = 3,
    textsize = 8,
    -- Small, unobtrusive — healers need screen space
    showtitle = false,
    showunitname = true,
    showhealthbar = true,
    showtargetindicator = false,
    -- Only critical raid debuffs
    orderfront = "otherraid",
    ordermiddle = "ownraid",
    orderback = "ownclass",
    orderlast = "otherclass",
    shareddebuffs = {
        mortalstrike = true, woundpoison = true,
        thunderclap = true, demoshout = true, demoroar = true,
        sunderarmor = true, faeriefire = true,
    },
    borderownclass = "off",
    borderotherclass = "off",
    borderownraid = "off",
    borderotherraid = "red",
    borderwidth = 2,
    armorStatusEnabled = false,
    filterincombat = true,
    filterhostile = true,
}

-- ============================================================
-- 6. ROGUE — Expose Armor & CC tracking
-- ============================================================
CursiveDefaultProfiles["Rogue"] = {
    maxcurses = 6,
    maxrow = 8,
    height = 16,
    curseiconsize = 16,
    orderfront = "ownclass",
    ordermiddle = "ownraid",
    orderback = "otherraid",
    orderlast = "otherclass",
    shareddebuffs = {
        exposearmor = true, sunderarmor = true, faeriefire = true,
        woundpoison = true, sap = true,
        curseofrecklessness = true, armorshatter = true, puncturearmor = true,
        mortalstrike = true, huntersmark = true,
    },
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "green",
    borderotherraid = "off",
    borderwidth = 2,
    coloreddecimalduration = true,
    armorStatusEnabled = true,
    armorDisplayStructure = "live+removed",
}

-- ============================================================
-- 7. HUNTER — Marks & CC oversight
-- ============================================================
CursiveDefaultProfiles["Hunter"] = {
    maxcurses = 6,
    maxrow = 8,
    height = 16,
    curseiconsize = 16,
    orderfront = "ownclass",
    ordermiddle = "otherraid",
    orderback = "ownraid",
    orderlast = "otherclass",
    shareddebuffs = {
        huntersmark = true, freezingtrap = true, scattershot = true, wyvernsting = true,
        sunderarmor = true, faeriefire = true,
        mortalstrike = true, thunderclap = true,
    },
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "off",
    borderotherraid = "off",
    armorStatusEnabled = false,
}

-- ============================================================
-- 8. PRIEST — Shadow Weaving + Shackle
-- ============================================================
CursiveDefaultProfiles["Priest"] = {
    maxcurses = 6,
    maxrow = 8,
    height = 15,
    curseiconsize = 16,
    scale = 0.95,
    orderfront = "ownclass",
    ordermiddle = "ownraid",
    orderback = "otherraid",
    orderlast = "otherclass",
    shareddebuffs = {
        shadowweaving = true, shackleundead = true, mindcontrol = true, psychicscream = true,
        curseofshadow = true, shadowvulnerability = true,
        sunderarmor = true, faeriefire = true,
        mortalstrike = true, woundpoison = true,
    },
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "green",
    borderotherraid = "off",
    coloreddecimalduration = true,
    armorStatusEnabled = false,
}

-- ============================================================
-- 9. COMPACT — Minimal screen footprint
-- ============================================================
CursiveDefaultProfiles["Compact"] = {
    maxcurses = 4,
    maxrow = 6,
    maxcol = 1,
    height = 12,
    healthwidth = 60,
    curseiconsize = 12,
    raidiconsize = 12,
    scale = 0.85,
    spacing = 2,
    textsize = 7,
    nameTextSize = 7,
    cursetimersize = 9,
    namelength = 50,
    -- Strip it down
    showtitle = false,
    showunitname = false,
    showhealthbar = true,
    showtargetindicator = true,
    showraidicons = true,
    -- Only essentials
    shareddebuffs = {
        sunderarmor = true, faeriefire = true, curseofrecklessness = true,
        curseoftheelements = true, curseofshadow = true,
    },
    borderownclass = "off",
    borderotherclass = "off",
    borderownraid = "off",
    borderotherraid = "off",
    armorStatusEnabled = false,
    filterincombat = true,
    filterhostile = true,
    filterattackable = true,
}

-- ============================================================
-- 10. WIDE — Multi-column for large raids (AQ40/Naxx)
-- ============================================================
CursiveDefaultProfiles["Wide"] = {
    maxcurses = 8,
    maxrow = 10,
    maxcol = 2,
    height = 14,
    healthwidth = 80,
    curseiconsize = 14,
    raidiconsize = 14,
    scale = 0.95,
    spacing = 3,
    showtitle = true,
    showraidicons = true,
    showhealthbar = true,
    showunitname = true,
    showtargetindicator = true,
    alwaysshowcurrenttarget = true,
    shareddebuffs = {
        sunderarmor = true, exposearmor = true, faeriefire = true, curseofrecklessness = true,
        curseoftheelements = true, curseofshadow = true,
        firevulnerability = true, winterschill = true, shadowweaving = true,
        mortalstrike = true, thunderclap = true, demoshout = true,
    },
    armorStatusEnabled = true,
    armorDisplayStructure = "live+removed",
    filterincombat = true,
    filterhostile = true,
}

-- ============================================================
-- 11. PVP — Player tracking, CC awareness
-- ============================================================
CursiveDefaultProfiles["PvP"] = {
    maxcurses = 6,
    maxrow = 8,
    height = 16,
    curseiconsize = 16,
    scale = 1.0,
    -- Show player targets
    filterincombat = false,  -- PvP: track out of combat too
    filterhostile = true,
    filterattackable = true,
    -- CC debuffs are king in PvP
    shareddebuffs = {
        polymorph = true, fear = true, howlofterror = true, psychicscream = true,
        intimidatingshout = true, hammerofjustice = true, sap = true,
        freezingtrap = true, scattershot = true, wyvernsting = true,
        banish = true, seduction = true, hibernate = true,
        shackleundead = true, mindcontrol = true,
        mortalstrike = true, woundpoison = true,
    },
    orderfront = "otherclass",
    ordermiddle = "ownclass",
    orderback = "otherraid",
    orderlast = "ownraid",
    -- Red borders on CC to spot breaks fast
    borderownclass = "green",
    borderotherclass = "red",
    borderownraid = "off",
    borderotherraid = "red",
    borderwidth = 3,
    borderopacity = 100,
    coloreddecimalduration = true,
    armorStatusEnabled = false,
}

-- ============================================================
-- 12. DRUID — Faerie Fire, Roar, CC tracking
-- ============================================================
CursiveDefaultProfiles["Druid"] = {
    maxcurses = 6,
    maxrow = 8,
    height = 16,
    curseiconsize = 16,
    orderfront = "ownclass",
    ordermiddle = "ownraid",
    orderback = "otherraid",
    orderlast = "otherclass",
    shareddebuffs = {
        faeriefire = true, demoroar = true, hibernate = true,
        sunderarmor = true, exposearmor = true, curseofrecklessness = true,
        mortalstrike = true, thunderclap = true, demoshout = true,
        huntersmark = true,
    },
    borderownclass = "green",
    borderotherclass = "off",
    borderownraid = "green",
    borderotherraid = "off",
    coloreddecimalduration = true,
    armorStatusEnabled = true,
    armorDisplayStructure = "live+removed",
}

-- ============================================================
-- Install defaults on first run
-- ============================================================
local installFrame = CreateFrame("Frame")
installFrame:RegisterEvent("PLAYER_LOGIN")
installFrame:SetScript("OnEvent", function()
    installFrame:UnregisterEvent("PLAYER_LOGIN")

    -- Only install if NO profiles exist yet (first run)
    if not CursiveProfiles then CursiveProfiles = {} end

    local hasAny = false
    for _ in pairs(CursiveProfiles) do hasAny = true; break end

    if not hasAny then
        for name, data in pairs(CursiveDefaultProfiles) do
            CursiveProfiles[name] = data
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r " .. 12 .. " default profiles installed. Open Profiles tab to browse.")
    end
end)

-- profilesUI.lua — Profile Tab for Cursive Raid Options UI
-- Adds a "Profiles" tab (tab 6) to CursiveOptionsFrame.
-- Lua 5.0 compatible (Vanilla 1.12 / TurtleWoW)
-- NO string.match(), string.gmatch(), #table, {...}, table.unpack(), self in handlers

local pairs = pairs
local ipairs = ipairs
local floor = math.floor
local format = string.format
local getn = table.getn
local tinsert = table.insert
local getglobal = getglobal

-- ============================================================
-- Constants (matching CursiveOptionsUI.lua)
-- ============================================================
local FRAME_WIDTH = 338
local TAB_GAP = 2
local TAB_HEIGHT = 22
local NEW_TAB_COUNT = 6
local NEW_TAB_WIDTH = floor((FRAME_WIDTH - (NEW_TAB_COUNT - 1) * TAB_GAP) / NEW_TAB_COUNT)

local PANEL_TOP_OFFSET = -48
local PANEL_BOTTOM_OFFSET = 62

local CONTENT_WIDTH = FRAME_WIDTH - 30  -- 308, used for reference
local INNER_WIDTH = FRAME_WIDTH - 10 - 12 - 44  -- 272: +12 left (was -24) but -20 right (was -24, now -44)

-- Theme colors: helper to avoid unpack() for CursiveOptionsUI.lua style consistency
local function SetTexColor(tex, r, g, b, a) tex:SetTexture(r, g, b, a) end
local function SetFSColor(fs, r, g, b) fs:SetTextColor(r, g, b) end

-- Color constants (r, g, b, a)
local C_ACTIVE_TAB_R, C_ACTIVE_TAB_G, C_ACTIVE_TAB_B, C_ACTIVE_TAB_A = 0.25, 0.25, 0.25, 1
local C_INACTIVE_TAB_R, C_INACTIVE_TAB_G, C_INACTIVE_TAB_B, C_INACTIVE_TAB_A = 0.15, 0.15, 0.15, 0.8
local C_HOVER_TAB_R, C_HOVER_TAB_G, C_HOVER_TAB_B, C_HOVER_TAB_A = 0.3, 0.3, 0.3, 1
local C_TEXT_ACTIVE_R, C_TEXT_ACTIVE_G, C_TEXT_ACTIVE_B = 1, 1, 1
local C_TEXT_INACTIVE_R, C_TEXT_INACTIVE_G, C_TEXT_INACTIVE_B = 0.82, 0.82, 0.82
local C_GOLD_R, C_GOLD_G, C_GOLD_B = 1, 0.82, 0
local C_GREEN_R, C_GREEN_G, C_GREEN_B = 0, 1, 0
local C_WHITE_R, C_WHITE_G, C_WHITE_B = 1, 1, 1
local C_DIM_R, C_DIM_G, C_DIM_B = 0.6, 0.6, 0.6

-- ============================================================
-- State
-- ============================================================
local selectedProfile = nil
local includePosition = true
local profilePanelBuilt = false

-- ============================================================
-- Wait for CursiveOptionsFrame to exist, then inject tab 6
-- ============================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    initFrame:UnregisterEvent("PLAYER_LOGIN")

    -- Delay one frame to ensure CursiveOptionsUI has created everything
    local delayFrame = CreateFrame("Frame")
    delayFrame:SetScript("OnUpdate", function()
        this:Hide()
        CursiveProfilesUI_Init()
    end)
    delayFrame:Show()
end)

-- ============================================================
-- Main init function
-- ============================================================
function CursiveProfilesUI_Init()
    local mainFrame = getglobal("CursiveOptionsFrame")
    if not mainFrame then return end

    -- --------------------------------------------------------
    -- Resize existing 5 tabs + create tab 6 to fill edge-to-edge
    -- --------------------------------------------------------
    -- Calculate widths: distribute pixels evenly, extra goes to rightmost tabs
    local totalGaps = (NEW_TAB_COUNT - 1) * TAB_GAP
    local availWidth = FRAME_WIDTH - totalGaps
    local baseWidth = floor(availWidth / NEW_TAB_COUNT)
    local remainder = availWidth - (baseWidth * NEW_TAB_COUNT)
    -- remainder pixels go to the LAST 'remainder' tabs (right-side absorbs slack)

    local allTabNames = {
        "CursiveTabGeneral", "CursiveTabRaid", "CursiveTabClass",
        "CursiveTabDisplay", "CursiveTabFilter", "CursiveTabProfiles",
    }

    local prevTab = nil
    for i, tName in ipairs(allTabNames) do
        if i <= 5 then
            -- Resize existing tabs
            local tab = getglobal(tName)
            if tab then
                local w = baseWidth
                if i > (NEW_TAB_COUNT - remainder) then w = w + 1 end
                tab:SetWidth(w)
                tab:ClearAllPoints()
                if i == 1 then
                    tab:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -(TAB_HEIGHT + 2))
                else
                    tab:SetPoint("LEFT", prevTab, "RIGHT", TAB_GAP, 0)
                end
                prevTab = tab
            end
        end
    end

    -- --------------------------------------------------------
    -- Create tab 6: "Profiles"
    -- --------------------------------------------------------
    local tabName = "CursiveTabProfiles"
    local tab6Width = baseWidth
    if 6 > (NEW_TAB_COUNT - remainder) then tab6Width = tab6Width + 1 end
    local tab6 = CreateFrame("Button", tabName, mainFrame)
    tab6:SetWidth(tab6Width)
    tab6:SetHeight(TAB_HEIGHT)
    tab6:SetPoint("LEFT", prevTab, "RIGHT", TAB_GAP, 0)

    local bg = tab6:CreateTexture(tabName .. "BG", "BACKGROUND")
    bg:SetTexture(C_INACTIVE_TAB_R, C_INACTIVE_TAB_G, C_INACTIVE_TAB_B, C_INACTIVE_TAB_A)
    bg:SetAllPoints(tab6)

    local tabText = tab6:CreateFontString(tabName .. "Text", "ARTWORK", "GameFontNormalSmall")
    tabText:SetPoint("CENTER", tab6, "CENTER", 0, 0)
    tabText:SetText("Profiles")
    tabText:SetTextColor(C_TEXT_INACTIVE_R, C_TEXT_INACTIVE_G, C_TEXT_INACTIVE_B)

    tab6.tabIndex = 6

    tab6:SetScript("OnEnter", function()
        local bgTex = getglobal(this:GetName() .. "BG")
        if this.tabIndex ~= CursiveProfilesUI_GetSelectedTab() then
            bgTex:SetTexture(C_HOVER_TAB_R, C_HOVER_TAB_G, C_HOVER_TAB_B, C_HOVER_TAB_A)
        end
        getglobal(this:GetName() .. "Text"):SetTextColor(C_TEXT_ACTIVE_R, C_TEXT_ACTIVE_G, C_TEXT_ACTIVE_B)
    end)
    tab6:SetScript("OnLeave", function()
        local bgTex = getglobal(this:GetName() .. "BG")
        if this.tabIndex ~= CursiveProfilesUI_GetSelectedTab() then
            bgTex:SetTexture(C_INACTIVE_TAB_R, C_INACTIVE_TAB_G, C_INACTIVE_TAB_B, C_INACTIVE_TAB_A)
        end
        getglobal(this:GetName() .. "Text"):SetTextColor(C_TEXT_INACTIVE_R, C_TEXT_INACTIVE_G, C_TEXT_INACTIVE_B)
    end)
    tab6:SetScript("OnClick", function()
        CursiveOpts.SelectTab(6)
    end)

    -- --------------------------------------------------------
    -- Create panel for tab 6
    -- --------------------------------------------------------
    local panel = CreateFrame("Frame", "CursiveProfilesPanel", mainFrame)
    panel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, PANEL_TOP_OFFSET)
    panel:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, PANEL_BOTTOM_OFFSET - 16)
    panel:Hide()

    -- --------------------------------------------------------
    -- Hook into SelectTab to handle tab 6
    -- --------------------------------------------------------
    local originalSelectTab = CursiveOpts and CursiveOpts.SelectTab

    CursiveOpts.SelectTab = function(tabIndex)
        -- Let original handle tabs 1-5
        if originalSelectTab then originalSelectTab(tabIndex) end

        -- Handle tab 6 visibility
        local profilePanel = getglobal("CursiveProfilesPanel")
        if profilePanel then
            if tabIndex == 6 then
                profilePanel:Show()
                -- Hide other panels (original already hides them, but be safe)
                for _, pName in ipairs({"CursiveGeneralPanel", "CursiveRaidPanel", "CursiveClassPanel", "CursiveDisplayPanel", "CursiveFilterPanel"}) do
                    local p = getglobal(pName)
                    if p then p:Hide() end
                end
                -- Hide buttons that belong to other tabs
                local toggleAll = getglobal("CursiveToggleAllBtn")
                if toggleAll then toggleAll:Hide() end
                local resetFrame = getglobal("CursiveResetFrameBtn")
                if resetFrame then resetFrame:Hide() end

                CursiveProfilesUI_Refresh()
            else
                profilePanel:Hide()
            end
        end

        -- Update tab 6 visuals
        local tab6BG = getglobal("CursiveTabProfilesBG")
        local tab6Text = getglobal("CursiveTabProfilesText")
        if tab6BG and tab6Text then
            if tabIndex == 6 then
                tab6BG:SetTexture(C_ACTIVE_TAB_R, C_ACTIVE_TAB_G, C_ACTIVE_TAB_B, C_ACTIVE_TAB_A)
                tab6Text:SetTextColor(C_TEXT_ACTIVE_R, C_TEXT_ACTIVE_G, C_TEXT_ACTIVE_B)
            else
                tab6BG:SetTexture(C_INACTIVE_TAB_R, C_INACTIVE_TAB_G, C_INACTIVE_TAB_B, C_INACTIVE_TAB_A)
                tab6Text:SetTextColor(C_TEXT_INACTIVE_R, C_TEXT_INACTIVE_G, C_TEXT_INACTIVE_B)
            end
        end
    end

    -- --------------------------------------------------------
    -- Build profile panel content
    -- --------------------------------------------------------
    CursiveProfilesUI_BuildPanel(panel)
end

-- Helper to get current selected tab (read from the tab highlight state)
function CursiveProfilesUI_GetSelectedTab()
    -- Check which tab has active color
    local tabs = {"CursiveTabGeneral","CursiveTabRaid","CursiveTabClass","CursiveTabDisplay","CursiveTabFilter","CursiveTabProfiles"}
    for i, name in ipairs(tabs) do
        local panel
        if i <= 5 then
            local pNames = {"CursiveGeneralPanel","CursiveRaidPanel","CursiveClassPanel","CursiveDisplayPanel","CursiveFilterPanel"}
            panel = getglobal(pNames[i])
        else
            panel = getglobal("CursiveProfilesPanel")
        end
        if panel and panel:IsShown() then return i end
    end
    return 1
end

-- ============================================================
-- Build the Profiles panel UI
-- ============================================================
function CursiveProfilesUI_BuildPanel(panel)
    if profilePanelBuilt then return end
    profilePanelBuilt = true

    local y = -27         -- +3px down from tabs
    local leftMargin = 15 -- +3px right from left edge

    -- ---- Header: Profile Management ----
    local header1 = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header1:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    header1:SetText("Profile Management")
    header1:SetTextColor(C_GOLD_R, C_GOLD_G, C_GOLD_B)
    local font, size, flags = header1:GetFont()
    header1:SetFont(font, size + 1, "OUTLINE")
    y = y - 22

    -- ---- Profile Dropdown (simulated with button + list) ----
    local dropLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    dropLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    dropLabel:SetText("Select Profile:")
    dropLabel:SetTextColor(C_DIM_R, C_DIM_G, C_DIM_B)
    y = y - 16

    -- Selected profile display
    local selectedDisplay = CreateFrame("Button", "CursiveProfileSelected", panel)
    selectedDisplay:SetWidth(INNER_WIDTH)
    selectedDisplay:SetHeight(22)
    selectedDisplay:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)

    local selBG = selectedDisplay:CreateTexture(nil, "BACKGROUND")
    selBG:SetAllPoints(selectedDisplay)
    selBG:SetTexture(0.12, 0.12, 0.12, 0.9)

    local selText = selectedDisplay:CreateFontString("CursiveProfileSelectedText", "ARTWORK", "GameFontHighlightSmall")
    selText:SetPoint("LEFT", selectedDisplay, "LEFT", 8, 0)
    selText:SetText("(no profile selected)")
    selText:SetTextColor(C_DIM_R, C_DIM_G, C_DIM_B)

    local selArrow = selectedDisplay:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    selArrow:SetPoint("RIGHT", selectedDisplay, "RIGHT", -8, 0)
    selArrow:SetText("v")
    selArrow:SetTextColor(C_DIM_R, C_DIM_G, C_DIM_B)

    -- Profile list frame (shown/hidden on click)
    local listFrame = CreateFrame("Frame", "CursiveProfileList", panel)
    listFrame:SetWidth(INNER_WIDTH)
    listFrame:SetHeight(1)  -- will resize
    listFrame:SetPoint("TOPLEFT", selectedDisplay, "BOTTOMLEFT", 0, -1)
    listFrame:SetFrameStrata("TOOLTIP")
    listFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    listFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    listFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    listFrame:Hide()
    listFrame.buttons = {}

    selectedDisplay:SetScript("OnClick", function()
        if listFrame:IsShown() then
            listFrame:Hide()
        else
            CursiveProfilesUI_PopulateList()
            listFrame:Show()
        end
    end)

    y = y - 39  -- 28 + 11px extra gap below dropdown

    -- ---- Action Buttons Row 1: Load / Save ----
    local btnWidth = floor((INNER_WIDTH - 6) / 2)
    local btnHeight = 22

    local loadBtn = CreateFrame("Button", "CursiveProfileLoadBtn", panel, "UIPanelButtonTemplate")
    loadBtn:SetWidth(btnWidth)
    loadBtn:SetHeight(btnHeight)
    loadBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    loadBtn:SetText("Load")
    loadBtn:SetScript("OnClick", function()
        if not selectedProfile then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Select a profile first.")
            return
        end
        -- Confirmation dialog
        StaticPopupDialogs["CURSIVE_PROFILE_CONFIRM_LOAD"] = {
            text = "Load profile \"|cFF33FFCC" .. selectedProfile .. "|r\"?\nThis will overwrite your current settings.",
            button1 = "Load",
            button2 = "Cancel",
            OnAccept = function()
                Cursive.profiles.Load(selectedProfile, includePosition)
                -- Refresh options UI if visible
                if CursiveOpts and CursiveOpts.Initialize then
                    CursiveOpts.Initialize()
                end
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
        }
        StaticPopup_Show("CURSIVE_PROFILE_CONFIRM_LOAD")
    end)
    do local fs = loadBtn:GetFontString(); if fs then local f,s,fl = fs:GetFont(); fs:SetFont(f,s-1,fl) end end

    local saveBtn = CreateFrame("Button", "CursiveProfileSaveBtn", panel, "UIPanelButtonTemplate")
    saveBtn:SetWidth(btnWidth)
    saveBtn:SetHeight(btnHeight)
    saveBtn:SetPoint("LEFT", loadBtn, "RIGHT", 6, 0)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        if selectedProfile then
            -- Overwrite existing
            StaticPopupDialogs["CURSIVE_PROFILE_CONFIRM_SAVE"] = {
                text = "Overwrite profile \"|cFF33FFCC" .. selectedProfile .. "|r\"?",
                button1 = "Save",
                button2 = "Cancel",
                OnAccept = function()
                    Cursive.profiles.Save(selectedProfile, includePosition)
                end,
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1,
            }
            StaticPopup_Show("CURSIVE_PROFILE_CONFIRM_SAVE")
        else
            -- No profile selected → prompt for new name
            StaticPopupDialogs["CURSIVE_PROFILE_NEW_SAVE"] = {
                text = "Enter a name for the new profile:",
                button1 = "Save",
                button2 = "Cancel",
                hasEditBox = 1,
                OnAccept = function()
                    local name = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
                    if name and name ~= "" then
                        local ok, err = Cursive.profiles.Save(name, includePosition)
                        if ok then
                            selectedProfile = name
                            CursiveProfilesUI_UpdateSelectedDisplay()
                        else
                            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r " .. (err or "Save failed"))
                        end
                    end
                end,
                EditBoxOnEnterPressed = function()
                    local name = this:GetText()
                    if name and name ~= "" then
                        local ok, err = Cursive.profiles.Save(name, includePosition)
                        if ok then
                            selectedProfile = name
                            CursiveProfilesUI_UpdateSelectedDisplay()
                        else
                            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r " .. (err or "Save failed"))
                        end
                    end
                    this:GetParent():Hide()
                end,
                EditBoxOnEscapePressed = function()
                    this:GetParent():Hide()
                end,
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1,
            }
            StaticPopup_Show("CURSIVE_PROFILE_NEW_SAVE")
        end
    end)
    do local fs = saveBtn:GetFontString(); if fs then local f,s,fl = fs:GetFont(); fs:SetFont(f,s-1,fl) end end

    y = y - (btnHeight + 4)

    -- ---- Action Buttons Row 2: Delete / New ----
    local deleteBtn = CreateFrame("Button", "CursiveProfileDeleteBtn", panel, "UIPanelButtonTemplate")
    deleteBtn:SetWidth(btnWidth)
    deleteBtn:SetHeight(btnHeight)
    deleteBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    deleteBtn:SetText("Delete")
    deleteBtn:SetScript("OnClick", function()
        if not selectedProfile then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Select a profile first.")
            return
        end
        StaticPopupDialogs["CURSIVE_PROFILE_CONFIRM_DELETE"] = {
            text = "Delete profile \"|cFFFF4444" .. selectedProfile .. "|r\"?\nThis cannot be undone.",
            button1 = "Delete",
            button2 = "Cancel",
            OnAccept = function()
                Cursive.profiles.Delete(selectedProfile)
                selectedProfile = nil
                CursiveProfilesUI_UpdateSelectedDisplay()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
        }
        StaticPopup_Show("CURSIVE_PROFILE_CONFIRM_DELETE")
    end)
    do local fs = deleteBtn:GetFontString(); if fs then local f,s,fl = fs:GetFont(); fs:SetFont(f,s-1,fl) end end

    local newBtn = CreateFrame("Button", "CursiveProfileNewBtn", panel, "UIPanelButtonTemplate")
    newBtn:SetWidth(btnWidth)
    newBtn:SetHeight(btnHeight)
    newBtn:SetPoint("LEFT", deleteBtn, "RIGHT", 6, 0)
    newBtn:SetText("Save As New")
    newBtn:SetScript("OnClick", function()
        StaticPopupDialogs["CURSIVE_PROFILE_CREATE"] = {
            text = "Enter a name for the new profile:",
            button1 = "Create",
            button2 = "Cancel",
            hasEditBox = 1,
            OnAccept = function()
                local name = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
                if name and name ~= "" then
                    local ok, err = Cursive.profiles.Save(name, includePosition)
                    if ok then
                        selectedProfile = name
                        CursiveProfilesUI_UpdateSelectedDisplay()
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r " .. (err or "Create failed"))
                    end
                end
            end,
            EditBoxOnEnterPressed = function()
                local name = this:GetText()
                if name and name ~= "" then
                    local ok, err = Cursive.profiles.Save(name, includePosition)
                    if ok then
                        selectedProfile = name
                        CursiveProfilesUI_UpdateSelectedDisplay()
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r " .. (err or "Create failed"))
                    end
                end
                this:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function()
                this:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
        }
        StaticPopup_Show("CURSIVE_PROFILE_CREATE")
    end)
    do local fs = newBtn:GetFontString(); if fs then local f,s,fl = fs:GetFont(); fs:SetFont(f,s-1,fl) end end

    y = y - (btnHeight + 8)

    -- ---- Checkbox: Include Position ----
    local posRow = CreateFrame("Frame", "CursiveProfilePosRow", panel)
    posRow:SetWidth(INNER_WIDTH)
    posRow:SetHeight(22)
    posRow:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)

    local posLabel = posRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    posLabel:SetPoint("LEFT", posRow, "LEFT", 0, 0)
    posLabel:SetText("Include frame position in profiles")
    local plf, pls, plfl = posLabel:GetFont()
    posLabel:SetFont(plf, pls + 1, plfl)

    local posCB = CreateFrame("CheckButton", "CursiveProfilePosCheck", posRow, "OptionsCheckButtonTemplate")
    posCB:SetWidth(22)
    posCB:SetHeight(22)
    posCB:SetPoint("RIGHT", posRow, "RIGHT", -16, 0)
    posCB:SetChecked(true)
    local cbText = getglobal("CursiveProfilePosCheckText")
    if cbText then cbText:SetText("") end
    posCB:SetScript("OnClick", function()
        includePosition = (this:GetChecked() == 1)
    end)

    y = y - 30

    -- ---- Header: Export / Import ----
    local header2 = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    header2:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    header2:SetText("Export / Import")
    header2:SetTextColor(C_GOLD_R, C_GOLD_G, C_GOLD_B)
    local h2f, h2s, h2fl = header2:GetFont()
    header2:SetFont(h2f, h2s + 1, "OUTLINE")
    y = y - 20

    -- ---- Export/Import Editbox ----
    local editBG = CreateFrame("Frame", "CursiveProfileEditBG", panel)
    editBG:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    editBG:SetWidth(INNER_WIDTH)
    editBG:SetHeight(120)
    editBG:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    editBG:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    editBG:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local scrollFrame = CreateFrame("ScrollFrame", "CursiveProfileEditScroll", editBG, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", editBG, "TOPLEFT", 6, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", editBG, "BOTTOMRIGHT", -24, 6)

    local editBox = CreateFrame("EditBox", "CursiveProfileEditBox", scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetWidth(INNER_WIDTH - 38)
    editBox:SetHeight(200)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    editBox:SetScript("OnTextChanged", function()
        scrollFrame:UpdateScrollChildRect()
    end)
    scrollFrame:SetScrollChild(editBox)

    y = y - 132  -- 126 + 6px extra gap below editbox

    -- ---- Export / Import buttons ----
    local expBtn = CreateFrame("Button", "CursiveProfileExportBtn", panel, "UIPanelButtonTemplate")
    expBtn:SetWidth(btnWidth)
    expBtn:SetHeight(btnHeight)
    expBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", leftMargin, y)
    expBtn:SetText("Export")
    expBtn:SetScript("OnClick", function()
        local str = Cursive.profiles.Export(selectedProfile, includePosition)
        if str then
            local eb = getglobal("CursiveProfileEditBox")
            if eb then
                eb:SetText(str)
                eb:HighlightText()
                eb:SetFocus()
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Profile exported. Copy the text above.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Export failed.")
        end
    end)
    do local fs = expBtn:GetFontString(); if fs then local f,s,fl = fs:GetFont(); fs:SetFont(f,s-1,fl) end end

    local impBtn = CreateFrame("Button", "CursiveProfileImportBtn", panel, "UIPanelButtonTemplate")
    impBtn:SetWidth(btnWidth)
    impBtn:SetHeight(btnHeight)
    impBtn:SetPoint("LEFT", expBtn, "RIGHT", 6, 0)
    impBtn:SetText("Import")
    impBtn:SetScript("OnClick", function()
        local eb = getglobal("CursiveProfileEditBox")
        if not eb then return end
        local str = eb:GetText()
        if not str or str == "" then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Paste a profile string into the text box first.")
            return
        end

        local ok, data, err = Cursive.profiles.Import(str)
        if not ok then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Import error: " .. (err or "unknown"))
            return
        end

        -- Ask for name
        StaticPopupDialogs["CURSIVE_PROFILE_IMPORT_NAME"] = {
            text = "Enter a name for the imported profile:",
            button1 = "Import",
            button2 = "Cancel",
            hasEditBox = 1,
            OnAccept = function()
                local name = getglobal(this:GetParent():GetName() .. "EditBox"):GetText()
                if name and name ~= "" then
                    CursiveProfiles[name] = data
                    selectedProfile = name
                    CursiveProfilesUI_UpdateSelectedDisplay()
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Profile imported as: |cFF00FF00" .. name .. "|r")
                end
            end,
            EditBoxOnEnterPressed = function()
                local name = this:GetText()
                if name and name ~= "" then
                    CursiveProfiles[name] = data
                    selectedProfile = name
                    CursiveProfilesUI_UpdateSelectedDisplay()
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFCC00Cursive:|r Profile imported as: |cFF00FF00" .. name .. "|r")
                end
                this:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function()
                this:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
        }
        StaticPopup_Show("CURSIVE_PROFILE_IMPORT_NAME")
    end)
    do local fs = impBtn:GetFontString(); if fs then local f,s,fl = fs:GetFont(); fs:SetFont(f,s-1,fl) end end

    y = y - (btnHeight + 12)
end

-- ============================================================
-- Populate dropdown list
-- ============================================================
function CursiveProfilesUI_PopulateList()
    if not Cursive.profiles then return end
    local listFrame = getglobal("CursiveProfileList")
    if not listFrame then return end

    -- Clear existing buttons
    for _, btn in ipairs(listFrame.buttons) do
        btn:Hide()
    end

    local names = Cursive.profiles.List()
    local count = getn(names)
    local itemHeight = 20
    local ly = -4

    if count == 0 then
        listFrame:SetHeight(itemHeight + 8)
        -- Show "no profiles" text
        if not listFrame.emptyText then
            listFrame.emptyText = listFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            listFrame.emptyText:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 8, -6)
            listFrame.emptyText:SetText("No saved profiles")
            listFrame.emptyText:SetTextColor(C_DIM_R, C_DIM_G, C_DIM_B)
        end
        listFrame.emptyText:Show()
        return
    end

    if listFrame.emptyText then listFrame.emptyText:Hide() end

    -- Create scroll frame if needed (for >16 profiles)
    local MAX_VISIBLE = 16
    if not listFrame.scrollFrame then
        local sf = CreateFrame("ScrollFrame", "CursiveProfileListScroll", listFrame)
        sf:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 2, -2)
        sf:SetPoint("BOTTOMRIGHT", listFrame, "BOTTOMRIGHT", -2, 2)
        local content = CreateFrame("Frame", "CursiveProfileListContent", sf)
        content:SetWidth(INNER_WIDTH - 4)
        content:SetHeight(1)
        sf:SetScrollChild(content)
        sf:SetScript("OnMouseWheel", function()  -- Lua 5.0: use arg1 not delta
            local cur = sf:GetVerticalScroll()
            local maxScroll = content:GetHeight() - sf:GetHeight()
            if maxScroll < 0 then maxScroll = 0 end
            local newScroll = cur - (arg1 * itemHeight * 2)
            if newScroll < 0 then newScroll = 0 end
            if newScroll > maxScroll then newScroll = maxScroll end
            sf:SetVerticalScroll(newScroll)
        end)
        sf:EnableMouseWheel(true)
        listFrame.scrollFrame = sf
        listFrame.scrollContent = content
    end

    local scrollContent = listFrame.scrollContent

    for i, name in ipairs(names) do
        local btn = listFrame.buttons[i]
        if not btn then
            btn = CreateFrame("Button", "CursiveProfileListItem" .. i, scrollContent)
            btn:SetWidth(INNER_WIDTH - 8)
            btn:SetHeight(itemHeight)
            btn:EnableMouse(true)

            local hl = btn:CreateTexture(nil, "HIGHLIGHT")
            hl:SetTexture(1, 1, 1, 0.1)
            hl:SetAllPoints(btn)

            local text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            text:SetPoint("LEFT", btn, "LEFT", 8, 0)
            text:SetJustifyH("LEFT")
            btn.text = text

            listFrame.buttons[i] = btn
        end

        btn:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 4, ly)
        btn.text:SetText(name)

        if name == selectedProfile then
            btn.text:SetTextColor(C_GREEN_R, C_GREEN_G, C_GREEN_B)
        else
            btn.text:SetTextColor(C_WHITE_R, C_WHITE_G, C_WHITE_B)
        end

        btn.profileName = name
        btn:SetScript("OnClick", function()
            selectedProfile = this.profileName
            CursiveProfilesUI_UpdateSelectedDisplay()
            listFrame:Hide()
        end)

        btn:Show()
        ly = ly - itemHeight
    end

    -- Set content height for scrolling
    scrollContent:SetHeight(count * itemHeight + 8)

    -- List frame height: dynamic up to MAX_VISIBLE, then fixed
    local visibleCount = count
    if visibleCount > MAX_VISIBLE then visibleCount = MAX_VISIBLE end
    local totalHeight = (visibleCount * itemHeight) + 8
    listFrame:SetHeight(totalHeight)

    -- Reset scroll position
    if listFrame.scrollFrame then
        listFrame.scrollFrame:SetVerticalScroll(0)
    end
end

-- ============================================================
-- Update the selected profile display text
-- ============================================================
function CursiveProfilesUI_UpdateSelectedDisplay()
    local selText = getglobal("CursiveProfileSelectedText")
    if not selText then return end

    if selectedProfile and Cursive.profiles.Exists(selectedProfile) then
        selText:SetText(selectedProfile)
        selText:SetTextColor(C_GREEN_R, C_GREEN_G, C_GREEN_B)
    elseif selectedProfile then
        -- Profile was deleted
        selectedProfile = nil
        selText:SetText("(no profile selected)")
        selText:SetTextColor(C_DIM_R, C_DIM_G, C_DIM_B)
    else
        selText:SetText("(no profile selected)")
        selText:SetTextColor(C_DIM_R, C_DIM_G, C_DIM_B)
    end
end

-- ============================================================
-- Refresh (called when tab 6 is selected)
-- ============================================================
function CursiveProfilesUI_Refresh()
    CursiveProfilesUI_UpdateSelectedDisplay()

    -- Update position checkbox
    local posCB = getglobal("CursiveProfilePosCheck")
    if posCB then
        posCB:SetChecked(includePosition)
    end
end

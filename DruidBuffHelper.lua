-- DruidBuffHelper for WoW Vanilla 1.12 (Turtle WoW)
-- Druid Buff Tracker for Party Members

-- Saved variables (persisted between sessions, initialized in OnAddonLoaded)

-- Addon namespace
DruidBuffHelper = {}
local addonLoaded = false

-- Buff textures to track (1.12 returns texture, not name)
local BUFF_MOTW_TEXTURE = "Interface\\Icons\\Spell_Nature_Regeneration"
local BUFF_THORNS_TEXTURE = "Interface\\Icons\\Spell_Nature_Thorns"

-- Spell names for casting
local SPELL_MARK_OF_THE_WILD = "Mark of the Wild"
local SPELL_THORNS = "Thorns"

-- Low buff threshold (seconds)
local LOW_BUFF_THRESHOLD = 60

-- Colors
local COLOR_GREEN = {0, 1, 0, 1}
local COLOR_RED = {1, 0, 0, 1}
local COLOR_WHITE = {1, 1, 1, 1}
local COLOR_HEADER = {1, 0.82, 0, 1}
local COLOR_DARK_GREEN = {0, 0.4, 0, 1}
local COLOR_DARK_RED = {0.4, 0, 0, 1}
local COLOR_YELLOW = {1, 1, 0, 1}

-- UI elements
local mainFrame = nil
local memberRows = {}
local modeButton = nil
local columnHeaders = {}

-- Buff state tracking for alerts
local buffState = {}

-- Create main frame for event handling
local eventFrame = CreateFrame("Frame")

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("SPELLCAST_STOP")

-- Event handler (1.12 style - no self, uses arg1, arg2, etc.)
eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        if arg1 == "DruidBuffHelper" then
            DruidBuffHelper:OnAddonLoaded()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        DruidBuffHelper:OnPlayerLogin()
    elseif event == "PARTY_MEMBERS_CHANGED" then
        DruidBuffHelper:CleanupBuffState()
        DruidBuffHelper:UpdateBuffPanel()
    elseif event == "UNIT_AURA" then
        if arg1 == "player" or arg1 == "party1" or arg1 == "party2" or arg1 == "party3" or arg1 == "party4" then
            DruidBuffHelper:UpdateBuffPanel()
        end
    elseif event == "SPELLCAST_STOP" then
        -- Update panel after casting
        DruidBuffHelper:UpdateBuffPanel()
    end
end)

-- Check if unit has a buff by texture; returns hasBuff, timeLeftSeconds (nil if unknown)
function DruidBuffHelper:UnitHasBuffTexture(unit, texture)
    local i = 1
    while true do
        -- Turtle WoW UnitBuff returns: texture, stacks, type, duration, expirationTime
        local tex, stacks, buffType, duration, expirationTime = UnitBuff(unit, i)
        if not tex then break end
        if tex == texture then
            local timeLeft = nil
            if expirationTime and expirationTime > 0 then
                timeLeft = expirationTime - GetTime()
                if timeLeft < 0 then timeLeft = 0 end
            end
            return true, timeLeft
        end
        i = i + 1
    end
    return false, nil
end

-- Check if unit has Mark of the Wild (or Gift of the Wild - same icon); returns hasBuff, timeLeft
function DruidBuffHelper:HasMarkOfTheWild(unit)
    return self:UnitHasBuffTexture(unit, BUFF_MOTW_TEXTURE)
end

-- Check if unit has Thorns; returns hasBuff, timeLeft
function DruidBuffHelper:HasThorns(unit)
    return self:UnitHasBuffTexture(unit, BUFF_THORNS_TEXTURE)
end

-- Get class color for unit
function DruidBuffHelper:GetClassColor(unit)
    local _, class = UnitClass(unit)
    if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        local color = RAID_CLASS_COLORS[class]
        return {color.r, color.g, color.b, 1}
    end
    return COLOR_WHITE
end

-- Get buff tracking settings for a character (defaults: both buffs enabled)
function DruidBuffHelper:GetBuffTracking(characterName)
    if not characterName then return { motw = true, thorns = true } end

    if not DruidBuffHelperDB.buffTracking then
        DruidBuffHelperDB.buffTracking = {}
    end

    if not DruidBuffHelperDB.buffTracking[characterName] then
        DruidBuffHelperDB.buffTracking[characterName] = { motw = true, thorns = true }
    end

    return DruidBuffHelperDB.buffTracking[characterName]
end

-- Set buff tracking for a specific character and buff type
function DruidBuffHelper:SetBuffTracking(characterName, buffType, enabled)
    if not characterName then return end

    if not DruidBuffHelperDB.buffTracking then
        DruidBuffHelperDB.buffTracking = {}
    end

    if not DruidBuffHelperDB.buffTracking[characterName] then
        DruidBuffHelperDB.buffTracking[characterName] = { motw = true, thorns = true }
    end

    DruidBuffHelperDB.buffTracking[characterName][buffType] = enabled
end

-- Check if member should be shown in operational mode
function DruidBuffHelper:ShouldShowMember(unit, name)
    -- In config mode, always show all members
    if DruidBuffHelperDB.mode == "config" then
        return true
    end

    -- In operational mode, hide members who are too far away
    -- UnitIsVisible returns false if unit is not rendered (too far)
    -- CheckInteractDistance(unit, 4) checks ~28 yards (close to buff range)
    if unit ~= "player" then
        if not UnitIsVisible(unit) then
            return false
        end
        -- CheckInteractDistance 4 = follow distance (~28 yards), close to buff range (30 yards)
        if not CheckInteractDistance(unit, 4) then
            return false
        end
    end

    -- In operational mode, show only if member needs a tracked buff
    local tracking = self:GetBuffTracking(name)

    if tracking.motw then
        local hasBuff, timeLeft = self:HasMarkOfTheWild(unit)
        if not hasBuff then return true end
        if timeLeft and timeLeft < LOW_BUFF_THRESHOLD then return true end
    end

    if tracking.thorns then
        local hasBuff, timeLeft = self:HasThorns(unit)
        if not hasBuff then return true end
        if timeLeft and timeLeft < LOW_BUFF_THRESHOLD then return true end
    end

    return false
end

-- Toggle between config and operational modes
function DruidBuffHelper:ToggleMode()
    if DruidBuffHelperDB.mode == "config" then
        DruidBuffHelperDB.mode = "operational"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r: Operational mode - showing members needing buffs")
    else
        DruidBuffHelperDB.mode = "config"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r: Config mode - configure buff tracking")
    end
    self:UpdateModeButton()
    self:UpdateBuffPanel()
end

-- Update mode button appearance
function DruidBuffHelper:UpdateModeButton()
    if not modeButton then return end
    if DruidBuffHelperDB.mode == "config" then
        modeButton.text:SetText("C")
        modeButton.text:SetTextColor(0, 1, 0, 1)  -- Green for config
    else
        modeButton.text:SetText("O")
        modeButton.text:SetTextColor(1, 0.82, 0, 1)  -- Gold for operational
    end
end

-- Cast a buff on a unit
function DruidBuffHelper:CastBuffOnUnit(unit, spellName)
    if not unit or not spellName then return end
    if not UnitExists(unit) then return end
    if UnitIsDeadOrGhost(unit) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r: Target is dead!")
        return
    end
    if not UnitIsConnected(unit) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r: Target is offline!")
        return
    end
    
    -- Target the unit, cast, then target previous
    TargetUnit(unit)
    CastSpellByName(spellName)
    TargetLastTarget()
end

-- Create a buff button with spell icon
function DruidBuffHelper:CreateBuffButton(parent, name, xPos, yPos, spellName, iconTexture)
    local size = 20
    local btn = CreateFrame("Button", name, parent)
    btn:SetWidth(size)
    btn:SetHeight(size)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, yPos)
    
    -- Icon texture (the spell icon)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(btn)
    icon:SetTexture(iconTexture)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = icon
    
    -- Red overlay for missing buff (solid color, same size)
    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetAllPoints(btn)
    overlay:SetTexture(1, 0, 0, 0.5)
    overlay:Hide()
    btn.overlay = overlay
    
    -- Thin border
    local border = btn:CreateTexture(nil, "BACKGROUND")
    border:SetWidth(size + 2)
    border:SetHeight(size + 2)
    border:SetPoint("CENTER", btn, "CENTER", 0, 0)
    border:SetTexture(0, 0, 0, 1)
    btn.border = border
    
    -- Highlight on mouseover
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(btn)
    highlight:SetTexture(1, 1, 1, 0.3)
    
    -- Store spell name
    btn.spellName = spellName
    btn.unit = nil
    
    -- Click handler
    btn:SetScript("OnClick", function()
        if this.unit and this.spellName then
            DruidBuffHelper:CastBuffOnUnit(this.unit, this.spellName)
        end
    end)
    
    -- Tooltip
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if this.hasBuff then
            if this.lowTime then
                GameTooltip:SetText(this.spellName .. " - Less than 1 min left!", COLOR_YELLOW[1], COLOR_YELLOW[2], COLOR_YELLOW[3])
            else
                GameTooltip:SetText(this.spellName .. " - Active", COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3])
            end
        else
            GameTooltip:SetText("Click to cast " .. this.spellName, COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    btn.hasBuff = false
    return btn
end

-- Update button appearance based on buff status (hasBuff, lowTime = < 1 min left)
function DruidBuffHelper:UpdateBuffButton(btn, hasBuff, lowTime)
    btn.hasBuff = hasBuff
    btn.lowTime = lowTime
    if hasBuff then
        if lowTime then
            btn.icon:SetVertexColor(COLOR_YELLOW[1], COLOR_YELLOW[2], COLOR_YELLOW[3], 1)
            btn.overlay:Hide()
            btn.border:SetTexture(0.8, 0.8, 0, 1) -- Yellow border
        else
            btn.icon:SetVertexColor(1, 1, 1, 1)
            btn.overlay:Hide()
            btn.border:SetTexture(0, 0.6, 0, 1) -- Green border
        end
    else
        btn.icon:SetVertexColor(0.4, 0.4, 0.4, 1)
        btn.overlay:Show()
        btn.border:SetTexture(0.6, 0, 0, 1) -- Red border
    end
end

-- Create the buff tracking panel
function DruidBuffHelper:CreateBuffPanel()
    if mainFrame then return end
    
    -- Main frame (1.12 style - no BackdropTemplate)
    mainFrame = CreateFrame("Frame", "DruidBuffHelperPanel", UIParent)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetFrameLevel(10)
    mainFrame:SetWidth(150)
    mainFrame:SetHeight(140)
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetClampedToScreen(true)
    
    -- Backdrop (1.12 style)
    mainFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    mainFrame:SetBackdropColor(0, 0, 0, 0.9)
    
    -- Drag functionality (1.12 style)
    mainFrame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    mainFrame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        -- Save position
        local point, _, relativePoint, xOfs, yOfs = this:GetPoint()
        DruidBuffHelperDB.position = { point = point, relativePoint = relativePoint, x = xOfs, y = yOfs }
    end)
    
    -- Title
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", mainFrame, "TOP", 0, -8)
    title:SetText("Druid Buffs")
    title:SetTextColor(COLOR_HEADER[1], COLOR_HEADER[2], COLOR_HEADER[3], COLOR_HEADER[4])
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    closeBtn:SetWidth(20)
    closeBtn:SetHeight(20)
    closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
        DruidBuffHelperDB.enabled = false
    end)

    -- Mode switch button
    modeButton = CreateFrame("Button", "DruidBuffHelperModeBtn", mainFrame)
    modeButton:SetWidth(16)
    modeButton:SetHeight(14)
    modeButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 6, -7)

    modeButton.text = modeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modeButton.text:SetAllPoints(modeButton)
    modeButton.text:SetText("O")
    modeButton.text:SetTextColor(1, 0.82, 0, 1)

    modeButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

    modeButton:SetScript("OnClick", function()
        DruidBuffHelper:ToggleMode()
    end)

    modeButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if DruidBuffHelperDB.mode == "config" then
            GameTooltip:SetText("Config Mode: Configure which buffs to track.\nClick to switch to Operational Mode.", 1, 1, 1)
        else
            GameTooltip:SetText("Operational Mode: Shows members needing buffs.\nClick to switch to Config Mode.", 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    modeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Column positions
    local col1X = 8
    local col2X = 95
    local col3X = 120

    -- Column headers (shown in config mode only)
    columnHeaders.motw = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    columnHeaders.motw:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col2X, -22)
    columnHeaders.motw:SetText("MW")
    columnHeaders.motw:SetTextColor(0.7, 0.7, 0.7, 1)
    columnHeaders.motw:Hide()

    columnHeaders.thorns = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    columnHeaders.thorns:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col3X, -22)
    columnHeaders.thorns:SetText("Th")
    columnHeaders.thorns:SetTextColor(0.7, 0.7, 0.7, 1)
    columnHeaders.thorns:Hide()

    -- Create rows for player + 4 party members
    local rowHeight = 22
    local startY = -22

    for i = 1, 5 do
        local row = {}
        local yPos = startY - (i - 1) * rowHeight

        -- Name
        row.name = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.name:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col1X, yPos - 5)
        row.name:SetWidth(85)
        row.name:SetJustifyH("LEFT")
        row.name:SetText("")

        -- Mark of the Wild button
        row.motwBtn = self:CreateBuffButton(mainFrame, "DruidBuffHelperMotwBtn"..i, col2X, yPos, SPELL_MARK_OF_THE_WILD, BUFF_MOTW_TEXTURE)
        row.motwBtn:Hide()

        -- Thorns button
        row.thornsBtn = self:CreateBuffButton(mainFrame, "DruidBuffHelperThornsBtn"..i, col3X, yPos, SPELL_THORNS, BUFF_THORNS_TEXTURE)
        row.thornsBtn:Hide()

        -- Mark of the Wild checkbox (for config mode)
        row.motwCheckbox = CreateFrame("CheckButton", "DruidBuffHelperMotwCb"..i, mainFrame, "UICheckButtonTemplate")
        row.motwCheckbox:SetWidth(20)
        row.motwCheckbox:SetHeight(20)
        row.motwCheckbox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col2X, yPos)
        row.motwCheckbox:SetChecked(true)
        row.motwCheckbox:Hide()
        row.motwCheckbox.rowIndex = i

        row.motwCheckbox:SetScript("OnClick", function()
            local rowIdx = this.rowIndex
            local charName = memberRows[rowIdx].characterName
            if charName then
                DruidBuffHelper:SetBuffTracking(charName, "motw", this:GetChecked())
            end
        end)

        row.motwCheckbox:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText("Track Mark of the Wild", 1, 1, 1)
            GameTooltip:Show()
        end)

        row.motwCheckbox:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- Thorns checkbox (for config mode)
        row.thornsCheckbox = CreateFrame("CheckButton", "DruidBuffHelperThornsCb"..i, mainFrame, "UICheckButtonTemplate")
        row.thornsCheckbox:SetWidth(20)
        row.thornsCheckbox:SetHeight(20)
        row.thornsCheckbox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col3X, yPos)
        row.thornsCheckbox:SetChecked(true)
        row.thornsCheckbox:Hide()
        row.thornsCheckbox.rowIndex = i

        row.thornsCheckbox:SetScript("OnClick", function()
            local rowIdx = this.rowIndex
            local charName = memberRows[rowIdx].characterName
            if charName then
                DruidBuffHelper:SetBuffTracking(charName, "thorns", this:GetChecked())
            end
        end)

        row.thornsCheckbox:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText("Track Thorns", 1, 1, 1)
            GameTooltip:Show()
        end)

        row.thornsCheckbox:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        row.unit = nil
        row.characterName = nil
        row.visible = false
        memberRows[i] = row
    end
    
    -- Restore saved position
    if DruidBuffHelperDB and DruidBuffHelperDB.position then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint(
            DruidBuffHelperDB.position.point,
            UIParent,
            DruidBuffHelperDB.position.relativePoint,
            DruidBuffHelperDB.position.x,
            DruidBuffHelperDB.position.y
        )
    end
    
    -- Always show initially (OnAddonLoaded will handle proper visibility)
    mainFrame:Show()
end

-- Clean up buff state for members who left the party
function DruidBuffHelper:CleanupBuffState()
    local currentMembers = {}
    
    -- Get current party member names
    local playerName = UnitName("player")
    if playerName then
        currentMembers[playerName] = true
    end
    
    local numPartyMembers = GetNumPartyMembers()
    if numPartyMembers and numPartyMembers > 0 then
        for i = 1, numPartyMembers do
            local name = UnitName("party" .. i)
            if name then
                currentMembers[name] = true
            end
        end
    end
    
    -- Remove state for members who left
    local toRemove = {}
    for name in pairs(buffState) do
        if not currentMembers[name] then
            table.insert(toRemove, name)
        end
    end
    for i = 1, table.getn(toRemove) do
        buffState[toRemove[i]] = nil
    end
end

-- Check buff and alert if it was lost; also alert if < 1 min left
function DruidBuffHelper:CheckBuffAndAlert(unit, name, buffType, hasBuff, timeLeft)
    if not name then return hasBuff end
    
    -- Initialize state for this unit if needed
    if not buffState[name] then
        buffState[name] = {}
    end
    
    local prevState = buffState[name][buffType]
    local lowTime = timeLeft and timeLeft < LOW_BUFF_THRESHOLD
    local lowKey = buffType .. "_lowAlert"
    local prevLowAlert = buffState[name][lowKey]
    
    -- Alert if buff was lost (had it before, doesn't have it now)
    if prevState and not hasBuff then
        local spellName
        if buffType == "motw" then
            spellName = SPELL_MARK_OF_THE_WILD
        else
            spellName = SPELL_THORNS
        end
        local numParty = GetNumPartyMembers()
        if numParty and numParty > 0 then
            SendChatMessage(name .. " needs " .. spellName .. "!", "PARTY")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[DruidBuffHelper]|r |cffff0000" .. name .. "|r needs |cff00ff00" .. spellName .. "|r!")
        end
    end
    
    -- Alert if less than 1 min left (once per drop below threshold)
    if hasBuff and lowTime and not prevLowAlert then
        local spellName = buffType == "motw" and SPELL_MARK_OF_THE_WILD or SPELL_THORNS
        local sec = math.floor(timeLeft)
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[DruidBuffHelper]|r |cffffff00" .. name .. "|r: " .. spellName .. " has less than 1 min left (" .. sec .. "s)!")
        buffState[name][lowKey] = true
    elseif not lowTime or not hasBuff then
        buffState[name][lowKey] = false
    end
    
    -- Save current state
    buffState[name][buffType] = hasBuff
    
    return hasBuff
end

-- Update the buff panel with current party status
function DruidBuffHelper:UpdateBuffPanel()
    if not addonLoaded then return end
    if not mainFrame then return end
    if not DruidBuffHelperDB or not DruidBuffHelperDB.enabled then return end

    local isConfigMode = (DruidBuffHelperDB.mode == "config")

    -- Show/hide column headers based on mode
    if isConfigMode then
        columnHeaders.motw:Show()
        columnHeaders.thorns:Show()
    else
        columnHeaders.motw:Hide()
        columnHeaders.thorns:Hide()
    end

    -- Hide all rows first
    for i = 1, 5 do
        memberRows[i].name:SetText("")
        memberRows[i].motwBtn:Hide()
        memberRows[i].thornsBtn:Hide()
        memberRows[i].motwCheckbox:Hide()
        memberRows[i].thornsCheckbox:Hide()
        memberRows[i].unit = nil
        memberRows[i].characterName = nil
        memberRows[i].visible = false
    end

    local rowIndex = 1

    -- Layout constants
    local col1X = 8
    local col2X = 95
    local col3X = 120
    local rowHeight = 22
    local startY = isConfigMode and -34 or -22

    -- Helper function to display a member
    local function displayMember(unit, name)
        if not self:ShouldShowMember(unit, name) then
            return false
        end

        local row = memberRows[rowIndex]
        local yPos = startY - (rowIndex - 1) * rowHeight

        -- Reposition elements based on mode
        row.name:ClearAllPoints()
        row.name:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col1X, yPos - 5)

        row.motwBtn:ClearAllPoints()
        row.motwBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col2X, yPos)
        row.thornsBtn:ClearAllPoints()
        row.thornsBtn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col3X, yPos)

        row.motwCheckbox:ClearAllPoints()
        row.motwCheckbox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col2X, yPos)
        row.thornsCheckbox:ClearAllPoints()
        row.thornsCheckbox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col3X, yPos)

        local classColor = self:GetClassColor(unit)
        row.name:SetText(name)
        row.name:SetTextColor(classColor[1], classColor[2], classColor[3], classColor[4])
        row.unit = unit
        row.characterName = name

        local tracking = self:GetBuffTracking(name)

        if isConfigMode then
            -- Config mode: show checkboxes, hide buttons
            row.motwCheckbox:SetChecked(tracking.motw)
            row.motwCheckbox:Show()
            row.thornsCheckbox:SetChecked(tracking.thorns)
            row.thornsCheckbox:Show()
        else
            -- Operational mode: show buttons, hide checkboxes
            row.motwBtn.unit = unit
            row.thornsBtn.unit = unit

            local hasMotw, motwTime = self:HasMarkOfTheWild(unit)
            local hasThorns, thornsTime = self:HasThorns(unit)

            -- Only alert for tracked buffs
            if tracking.motw then
                hasMotw = self:CheckBuffAndAlert(unit, name, "motw", hasMotw, motwTime)
            end
            if tracking.thorns then
                hasThorns = self:CheckBuffAndAlert(unit, name, "thorns", hasThorns, thornsTime)
            end

            local lowMotw = motwTime and motwTime < LOW_BUFF_THRESHOLD
            local lowThorns = thornsTime and thornsTime < LOW_BUFF_THRESHOLD

            self:UpdateBuffButton(row.motwBtn, hasMotw, lowMotw)
            self:UpdateBuffButton(row.thornsBtn, hasThorns, lowThorns)

            row.motwBtn:Show()
            row.thornsBtn:Show()
        end

        row.visible = true
        rowIndex = rowIndex + 1
        return true
    end

    -- Show player first
    local playerName = UnitName("player")
    if playerName then
        displayMember("player", playerName)
    end

    -- Check party members (1.12 style)
    local numPartyMembers = GetNumPartyMembers()
    if numPartyMembers and numPartyMembers > 0 then
        for i = 1, numPartyMembers do
            local unit = "party" .. i
            local name = UnitName(unit)

            if name and UnitExists(unit) then
                displayMember(unit, name)
            end
        end
    end

    -- Adjust frame height based on visible rows
    local visibleRows = rowIndex - 1
    local headerOffset = isConfigMode and 12 or 0
    local newHeight = 28 + headerOffset + (visibleRows * 22)
    mainFrame:SetHeight(math.max(50, newHeight))
end

-- Called when addon is loaded
function DruidBuffHelper:OnAddonLoaded()
    -- Initialize saved variables with defaults
    if not DruidBuffHelperDB or not DruidBuffHelperDB.initialized then
        DruidBuffHelperDB = {
            initialized = true,
            enabled = true,
            position = nil,
            mode = "operational",
            buffTracking = {},
        }
    end

    -- Migration: add new fields to existing DB
    if not DruidBuffHelperDB.mode then
        DruidBuffHelperDB.mode = "operational"
    end
    if not DruidBuffHelperDB.buffTracking then
        DruidBuffHelperDB.buffTracking = {}
    end

    -- Initialize addon components
    self:InitializeSlashCommands()
    self:CreateBuffPanel()

    addonLoaded = true

    -- Update mode button to match saved state
    self:UpdateModeButton()

    -- Force show the panel and update it
    if mainFrame then
        DruidBuffHelperDB.enabled = true
        mainFrame:Show()
        self:UpdateBuffPanel()
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r loaded! Type /dbh for commands.")
end

-- Called when player logs in
function DruidBuffHelper:OnPlayerLogin()
    if addonLoaded then
        self:UpdateBuffPanel()
    end
end

-- Initialize slash commands
function DruidBuffHelper:InitializeSlashCommands()
    SLASH_DRUIDBUFFHELPER1 = "/druidbuffhelper"
    SLASH_DRUIDBUFFHELPER2 = "/dbh"
    
    SlashCmdList["DRUIDBUFFHELPER"] = function(msg)
        -- 1.12 style string parsing (no string:match)
        msg = msg or ""
        local command = string.lower(msg)

        -- Remove leading/trailing spaces
        command = string.gsub(command, "^%s*(.-)%s*$", "%1")

        if command == "help" then
            DruidBuffHelper:PrintHelp()
        elseif command == "toggle" or command == "show" then
            DruidBuffHelper:Toggle()
        elseif command == "hide" then
            DruidBuffHelper:HidePanel()
        elseif command == "reset" then
            DruidBuffHelper:ResetPosition()
        elseif command == "mode" then
            DruidBuffHelper:ToggleMode()
        elseif command == "config" then
            DruidBuffHelperDB.mode = "config"
            DruidBuffHelper:UpdateModeButton()
            DruidBuffHelper:UpdateBuffPanel()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r: Config mode - configure buff tracking")
        elseif command == "op" or command == "operational" then
            DruidBuffHelperDB.mode = "operational"
            DruidBuffHelper:UpdateModeButton()
            DruidBuffHelper:UpdateBuffPanel()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r: Operational mode - showing members needing buffs")
        else
            DruidBuffHelper:Toggle()
        end
    end
end

-- Print help message
function DruidBuffHelper:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r commands:")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh - Toggle the buff panel")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh toggle - Toggle the buff panel")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh hide - Hide the buff panel")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh reset - Reset panel position")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh mode - Toggle config/operational mode")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh config - Switch to config mode")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh op - Switch to operational mode")
    DEFAULT_CHAT_FRAME:AddMessage("  /dbh help - Show this help message")
end

-- Toggle panel visibility
function DruidBuffHelper:Toggle()
    if mainFrame then
        if mainFrame:IsShown() then
            mainFrame:Hide()
            DruidBuffHelperDB.enabled = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r panel hidden")
        else
            mainFrame:Show()
            DruidBuffHelperDB.enabled = true
            self:UpdateBuffPanel()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r panel shown")
        end
    end
end

-- Hide panel
function DruidBuffHelper:HidePanel()
    if mainFrame then
        mainFrame:Hide()
        DruidBuffHelperDB.enabled = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r panel hidden")
    end
end

-- Reset panel position
function DruidBuffHelper:ResetPosition()
    if mainFrame then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        DruidBuffHelperDB.position = nil
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00DruidBuffHelper|r position reset")
    end
end

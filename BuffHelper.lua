-- BuffHelper for WoW Vanilla 1.12 (Turtle WoW)
-- Buff Tracker for Party Members

-- Saved variables (persisted between sessions, initialized in OnAddonLoaded)

-- Addon namespace
BuffHelper = {}
local addonLoaded = false

-- Buff Profiles - defines buffs for each class
-- To add a new class, simply add a new entry to this table
local BuffProfiles = {
    DRUID = {
        title = "Druid Buffs",
        buffs = {
            {
                id = "motw",
                spellName = "Mark of the Wild",
                texture = "Interface\\Icons\\Spell_Nature_Regeneration",
                headerText = "MW",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "thorns",
                spellName = "Thorns",
                texture = "Interface\\Icons\\Spell_Nature_Thorns",
                headerText = "Th",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "tigersfury",
                spellName = "Tiger's Fury",
                texture = "Interface\\Icons\\Ability_Mount_JungleTiger",
                headerText = "TF",
                lowTimeDefault = 2,
                chatAlertDefault = false,
                selfOnly = true,
            },
        }
    },
    MAGE = {
        title = "Mage Buffs",
        buffs = {
            {
                id = "ai",
                spellName = "Arcane Intellect",
                texture = "Interface\\Icons\\Spell_Holy_MagicalSentry",
                headerText = "AI",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "dampen",
                spellName = "Dampen Magic",
                texture = "Interface\\Icons\\Spell_Nature_AbolishMagic",
                headerText = "DM",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "frostarmor",
                spellName = "Frost Armor",
                texture = "Interface\\Icons\\Spell_Frost_FrostArmor02",
                headerText = "FA",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
            },
        }
    },
    PRIEST = {
        title = "Priest Buffs",
        buffs = {
            {
                id = "fortitude",
                spellName = "Power Word: Fortitude",
                texture = "Interface\\Icons\\Spell_Holy_WordFortitude",
                headerText = "PF",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "divinespirit",
                spellName = "Divine Spirit",
                texture = "Interface\\Icons\\Spell_Holy_DivineSpirit",
                headerText = "DS",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "shadowprot",
                spellName = "Shadow Protection",
                texture = "Interface\\Icons\\Spell_Shadow_AntiShadow",
                headerText = "SP",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "innerfire",
                spellName = "Inner Fire",
                texture = "Interface\\Icons\\Spell_Holy_InnerFire",
                headerText = "IF",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
            },
            {
                id = "shadowform",
                spellName = "Shadowform",
                texture = "Interface\\Icons\\Spell_Shadow_Shadowform",
                headerText = "SF",
                lowTimeDefault = 5,
                chatAlertDefault = false,
                selfOnly = true,
            },
        }
    },
    PALADIN = {
        title = "Paladin Buffs",
        buffs = {
            {
                id = "might",
                spellName = "Blessing of Might",
                texture = "Interface\\Icons\\Spell_Holy_FistOfJustice",
                headerText = "Mi",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "wisdom",
                spellName = "Blessing of Wisdom",
                texture = "Interface\\Icons\\Spell_Holy_SealOfWisdom",
                headerText = "Wi",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "kings",
                spellName = "Blessing of Kings",
                texture = "Interface\\Icons\\Spell_Magic_MageArmor",
                headerText = "Ki",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "salvation",
                spellName = "Blessing of Salvation",
                texture = "Interface\\Icons\\Spell_Holy_SealOfSalvation",
                headerText = "Sa",
                lowTimeDefault = 60,
                chatAlertDefault = true,
            },
            {
                id = "devotion",
                spellName = "Devotion Aura",
                texture = "Interface\\Icons\\Spell_Holy_DevotionAura",
                headerText = "DA",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
            },
        }
    },
    WARRIOR = {
        title = "Warrior Buffs",
        buffs = {
            {
                id = "battleshout",
                spellName = "Battle Shout",
                texture = "Interface\\Icons\\Ability_Warrior_BattleShout",
                headerText = "BS",
                lowTimeDefault = 30,
                chatAlertDefault = true,
            },
            {
                id = "commandingshout",
                spellName = "Commanding Shout",
                texture = "Interface\\Icons\\Ability_Warrior_RallyingCry",
                headerText = "CS",
                lowTimeDefault = 30,
                chatAlertDefault = true,
            },
        }
    },
    SHAMAN = {
        title = "Shaman Buffs",
        buffs = {
            {
                id = "windfury",
                spellName = "Windfury Totem",
                texture = "Interface\\Icons\\Spell_Nature_Windfury",
                headerText = "WF",
                lowTimeDefault = 30,
                chatAlertDefault = true,
            },
            {
                id = "strengthofearth",
                spellName = "Strength of Earth Totem",
                texture = "Interface\\Icons\\Spell_Nature_EarthBindTotem",
                headerText = "SE",
                lowTimeDefault = 30,
                chatAlertDefault = true,
            },
            {
                id = "graceofair",
                spellName = "Grace of Air Totem",
                texture = "Interface\\Icons\\Spell_Nature_InvisibilityTotem",
                headerText = "GA",
                lowTimeDefault = 30,
                chatAlertDefault = true,
            },
            {
                id = "manaspring",
                spellName = "Mana Spring Totem",
                texture = "Interface\\Icons\\Spell_Nature_ManaRegenTotem",
                headerText = "MS",
                lowTimeDefault = 30,
                chatAlertDefault = true,
            },
            {
                id = "lightningshield",
                spellName = "Lightning Shield",
                texture = "Interface\\Icons\\Spell_Nature_LightningShield",
                headerText = "LS",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
            },
            {
                id = "windfuryweapon",
                spellName = "Windfury Weapon",
                texture = "Interface\\Icons\\Spell_Nature_Cyclone",
                headerText = "WW",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "mainhand",
            },
            {
                id = "flametongueweapon",
                spellName = "Flametongue Weapon",
                texture = "Interface\\Icons\\Spell_Fire_FlameTounge",
                headerText = "FW",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "mainhand",
            },
            {
                id = "rockbiterweapon",
                spellName = "Rockbiter Weapon",
                texture = "Interface\\Icons\\Spell_Nature_RockBiter",
                headerText = "RW",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "mainhand",
            },
            {
                id = "frostbrandweapon",
                spellName = "Frostbrand Weapon",
                texture = "Interface\\Icons\\Spell_Frost_FrostBrand",
                headerText = "FB",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "mainhand",
            },
        }
    },
    WARLOCK = {
        title = "Warlock Buffs",
        buffs = {
            {
                id = "demonarmor",
                spellName = "Demon Armor",
                texture = "Interface\\Icons\\Spell_Shadow_RagingScream",
                headerText = "DA",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
            },
        }
    },
    ROGUE = {
        title = "Rogue Buffs",
        buffs = {
            {
                id = "instantpoison",
                spellName = "Instant Poison",
                texture = "Interface\\Icons\\Ability_Poisons",
                headerText = "IP",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "mainhand",
            },
            {
                id = "instantpoisonoh",
                spellName = "Instant Poison",
                texture = "Interface\\Icons\\Ability_Poisons",
                headerText = "IO",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "offhand",
            },
            {
                id = "deadlypoison",
                spellName = "Deadly Poison",
                texture = "Interface\\Icons\\Ability_Rogue_DualWeild",
                headerText = "DP",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "mainhand",
            },
            {
                id = "deadlypoisonoh",
                spellName = "Deadly Poison",
                texture = "Interface\\Icons\\Ability_Rogue_DualWeild",
                headerText = "DO",
                lowTimeDefault = 60,
                chatAlertDefault = false,
                selfOnly = true,
                weaponSlot = "offhand",
            },
        }
    },
}

-- Active profile (cached after first detection)
local activeProfile = nil

-- Colors
local COLOR_GREEN = {0, 1, 0, 1}
local COLOR_RED = {1, 0, 0, 1}
local COLOR_WHITE = {1, 1, 1, 1}
local COLOR_HEADER = {1, 0.82, 0, 1}
local COLOR_DARK_GREEN = {0, 0.4, 0, 1}
local COLOR_DARK_RED = {0.4, 0, 0, 1}
local COLOR_YELLOW = {1, 1, 0, 1}
local COLOR_PURPLE = {0.6, 0.2, 0.8, 1}

-- UI elements
local mainFrame = nil
local memberRows = {}
local modeButton = nil
local columnHeaders = {}
local thresholdInputs = {}

-- Buff state tracking for alerts
local buffState = {}

-- Create main frame for event handling
local eventFrame = CreateFrame("Frame")
local updateElapsed = 0
local UPDATE_INTERVAL = 1  -- Refresh every 1 second to catch low time buffs

-- Register events
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("SPELLCAST_STOP")

-- Periodic update to catch buff time changes
eventFrame:SetScript("OnUpdate", function()
    updateElapsed = updateElapsed + arg1
    if updateElapsed >= UPDATE_INTERVAL then
        updateElapsed = 0
        if addonLoaded then
            BuffHelper:UpdateBuffPanel()
        end
    end
end)

-- Event handler (1.12 style - no self, uses arg1, arg2, etc.)
eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        if arg1 == "BuffHelper" then
            BuffHelper:OnAddonLoaded()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        BuffHelper:OnPlayerLogin()
    elseif event == "PARTY_MEMBERS_CHANGED" then
        BuffHelper:CleanupBuffState()
        BuffHelper:UpdateBuffPanel()
    elseif event == "UNIT_AURA" then
        if arg1 == "player" or arg1 == "party1" or arg1 == "party2" or arg1 == "party3" or arg1 == "party4" then
            BuffHelper:UpdateBuffPanel()
        end
    elseif event == "SPELLCAST_STOP" then
        -- Update panel after casting
        BuffHelper:UpdateBuffPanel()
    end
end)

-- Check if unit has a buff by texture; returns hasBuff, timeLeftSeconds (nil if unknown)
function BuffHelper:UnitHasBuffTexture(unit, texture)
    -- For player, use GetPlayerBuff API which supports time left
    if unit == "player" then
        local i = 0
        while true do
            local buffIndex = GetPlayerBuff(i, "HELPFUL")
            if buffIndex < 0 then break end
            local buffTexture = GetPlayerBuffTexture(buffIndex)
            if buffTexture == texture then
                local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
                if timeLeft and timeLeft > 0 then
                    return true, timeLeft
                end
                return true, nil
            end
            i = i + 1
        end
        return false, nil
    end

    -- For party members, use UnitBuff (no time available in vanilla)
    local i = 1
    while true do
        local tex = UnitBuff(unit, i)
        if not tex then break end
        if tex == texture then
            return true, nil  -- No time info available for party members
        end
        i = i + 1
    end
    return false, nil
end

-- Get the active buff profile for the player's class
function BuffHelper:GetActiveProfile()
    if activeProfile then return activeProfile end
    local _, playerClass = UnitClass("player")
    activeProfile = BuffProfiles[playerClass]
    return activeProfile
end

-- Get buff definition by ID from active profile
function BuffHelper:GetBuffDef(buffId)
    local profile = self:GetActiveProfile()
    if not profile then return nil end
    for _, buffDef in ipairs(profile.buffs) do
        if buffDef.id == buffId then
            return buffDef
        end
    end
    return nil
end

-- Check if unit has a specific buff; returns hasBuff, timeLeft
function BuffHelper:HasBuff(unit, buffDef)
    if not buffDef then return false, nil end

    -- Weapon enchants: only detectable on player
    if buffDef.weaponSlot then
        if unit == "player" then
            return self:HasWeaponEnchant(buffDef.weaponSlot)
        end
        return false, nil  -- Can't detect party weapon enchants
    end

    -- Regular aura buff
    return self:UnitHasBuffTexture(unit, buffDef.texture)
end

-- Check if player has a weapon enchant on specified slot
-- Returns: hasEnchant, timeLeftSeconds
function BuffHelper:HasWeaponEnchant(slot)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges,
          hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()

    if slot == "mainhand" then
        if hasMainHandEnchant then
            return true, mainHandExpiration / 1000  -- Convert ms to seconds
        end
    elseif slot == "offhand" then
        if hasOffHandEnchant then
            return true, offHandExpiration / 1000
        end
    end
    return false, nil
end

-- Get class color for unit
function BuffHelper:GetClassColor(unit)
    local _, class = UnitClass(unit)
    if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        local color = RAID_CLASS_COLORS[class]
        return {color.r, color.g, color.b, 1}
    end
    return COLOR_WHITE
end

-- Build default tracking table from active profile (all buffs enabled)
function BuffHelper:GetDefaultTracking()
    local defaults = {}
    local profile = self:GetActiveProfile()
    if profile then
        for _, buffDef in ipairs(profile.buffs) do
            defaults[buffDef.id] = true
        end
    end
    return defaults
end

-- Get buff tracking settings for a character (defaults: all buffs from profile enabled)
function BuffHelper:GetBuffTracking(characterName)
    if not characterName then return self:GetDefaultTracking() end

    if not BuffHelperDB.buffTracking then
        BuffHelperDB.buffTracking = {}
    end

    if not BuffHelperDB.buffTracking[characterName] then
        BuffHelperDB.buffTracking[characterName] = self:GetDefaultTracking()
    end

    return BuffHelperDB.buffTracking[characterName]
end

-- Set buff tracking for a specific character and buff type
function BuffHelper:SetBuffTracking(characterName, buffType, enabled)
    if not characterName then return end

    if not BuffHelperDB.buffTracking then
        BuffHelperDB.buffTracking = {}
    end

    if not BuffHelperDB.buffTracking[characterName] then
        BuffHelperDB.buffTracking[characterName] = self:GetDefaultTracking()
    end

    BuffHelperDB.buffTracking[characterName][buffType] = enabled
end

-- Get low time threshold for a buff (returns saved value or default from profile)
function BuffHelper:GetLowTimeThreshold(buffId)
    -- Check saved thresholds first
    if BuffHelperDB and BuffHelperDB.lowTimeThresholds and BuffHelperDB.lowTimeThresholds[buffId] then
        return BuffHelperDB.lowTimeThresholds[buffId]
    end

    -- Fall back to default from buff definition
    local buffDef = self:GetBuffDef(buffId)
    if buffDef and buffDef.lowTimeDefault then
        return buffDef.lowTimeDefault
    end

    -- Ultimate fallback
    return 60
end

-- Set low time threshold for a buff
function BuffHelper:SetLowTimeThreshold(buffId, seconds)
    if not buffId then return end

    if not BuffHelperDB.lowTimeThresholds then
        BuffHelperDB.lowTimeThresholds = {}
    end

    BuffHelperDB.lowTimeThresholds[buffId] = seconds
end

-- Get chat alert setting for a buff (returns saved value or default from profile)
function BuffHelper:GetChatAlert(buffId)
    -- Check saved settings first
    if BuffHelperDB and BuffHelperDB.chatAlerts and BuffHelperDB.chatAlerts[buffId] ~= nil then
        return BuffHelperDB.chatAlerts[buffId]
    end

    -- Fall back to default from buff definition
    local buffDef = self:GetBuffDef(buffId)
    if buffDef and buffDef.chatAlertDefault ~= nil then
        return buffDef.chatAlertDefault
    end

    -- Ultimate fallback
    return true
end

-- Set chat alert setting for a buff
function BuffHelper:SetChatAlert(buffId, enabled)
    if not buffId then return end

    if not BuffHelperDB.chatAlerts then
        BuffHelperDB.chatAlerts = {}
    end

    BuffHelperDB.chatAlerts[buffId] = enabled
end

-- Check if member should be shown in operational mode
function BuffHelper:ShouldShowMember(unit, name)
    -- In config mode, always show all members
    if BuffHelperDB.mode == "config" then
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
    local profile = self:GetActiveProfile()

    if profile then
        for _, buffDef in ipairs(profile.buffs) do
            if tracking[buffDef.id] then
                local hasBuff, timeLeft = self:HasBuff(unit, buffDef)
                if not hasBuff then return true end
                local threshold = self:GetLowTimeThreshold(buffDef.id)
                if timeLeft and timeLeft < threshold then return true end
            end
        end
    end

    return false
end

-- Get buffs that need to be visible in operational mode
-- Returns a table of buffId => true for any buff that at least one visible member needs
function BuffHelper:GetVisibleBuffsForOperationalMode()
    local visibleBuffs = {}
    local profile = self:GetActiveProfile()
    if not profile then return visibleBuffs end

    -- Check player
    local playerName = UnitName("player")
    if playerName and self:ShouldShowMember("player", playerName) then
        local tracking = self:GetBuffTracking(playerName)
        for _, buffDef in ipairs(profile.buffs) do
            if tracking[buffDef.id] then
                local hasBuff, timeLeft = self:HasBuff("player", buffDef)
                if not hasBuff then
                    visibleBuffs[buffDef.id] = true
                elseif timeLeft then
                    local threshold = self:GetLowTimeThreshold(buffDef.id)
                    if timeLeft < threshold then
                        visibleBuffs[buffDef.id] = true
                    end
                end
            end
        end
    end

    -- Check party members
    local numPartyMembers = GetNumPartyMembers()
    if numPartyMembers and numPartyMembers > 0 then
        for i = 1, numPartyMembers do
            local unit = "party" .. i
            local name = UnitName(unit)
            if name and UnitExists(unit) and self:ShouldShowMember(unit, name) then
                local tracking = self:GetBuffTracking(name)
                for _, buffDef in ipairs(profile.buffs) do
                    if tracking[buffDef.id] then
                        local hasBuff, timeLeft = self:HasBuff(unit, buffDef)
                        if not hasBuff then
                            visibleBuffs[buffDef.id] = true
                        elseif timeLeft then
                            local threshold = self:GetLowTimeThreshold(buffDef.id)
                            if timeLeft < threshold then
                                visibleBuffs[buffDef.id] = true
                            end
                        end
                    end
                end
            end
        end
    end

    return visibleBuffs
end

-- Convert visible buffs table to ordered list of profile buff indexes
-- Preserves original order from profile.buffs
function BuffHelper:GetVisibleBuffIndexes(visibleBuffs)
    local indexes = {}
    local profile = self:GetActiveProfile()
    if not profile then return indexes end

    for buffIdx, buffDef in ipairs(profile.buffs) do
        if visibleBuffs[buffDef.id] then
            table.insert(indexes, buffIdx)
        end
    end

    return indexes
end

-- Toggle between config and operational modes
function BuffHelper:ToggleMode()
    if BuffHelperDB.mode == "config" then
        BuffHelperDB.mode = "operational"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r: Operational mode - showing members needing buffs")
    else
        BuffHelperDB.mode = "config"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r: Config mode - configure buff tracking")
    end
    self:UpdateModeButton()
    self:UpdateBuffPanel()
end

-- Update mode button appearance
function BuffHelper:UpdateModeButton()
    if not modeButton then return end
    if BuffHelperDB.mode == "config" then
        modeButton.text:SetText("C")
        modeButton.text:SetTextColor(0, 1, 0, 1)  -- Green for config
    else
        modeButton.text:SetText("O")
        modeButton.text:SetTextColor(1, 0.82, 0, 1)  -- Gold for operational
    end
end

-- Cast a buff on a unit
function BuffHelper:CastBuffOnUnit(unit, spellName, selfOnly)
    if not spellName then return end

    -- Self-only buffs: just cast without targeting
    if selfOnly then
        CastSpellByName(spellName)
        return
    end

    if not unit then return end
    if not UnitExists(unit) then return end
    if UnitIsDeadOrGhost(unit) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r: Target is dead!")
        return
    end
    if not UnitIsConnected(unit) then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r: Target is offline!")
        return
    end

    -- Target the unit, cast, then target previous
    TargetUnit(unit)
    CastSpellByName(spellName)
    TargetLastTarget()
end

-- Create a buff button with spell icon
function BuffHelper:CreateBuffButton(parent, name, xPos, yPos, spellName, iconTexture)
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
    btn.selfOnly = false

    -- Click handler
    btn:SetScript("OnClick", function()
        if this.spellName then
            BuffHelper:CastBuffOnUnit(this.unit, this.spellName, this.selfOnly)
        end
    end)
    
    -- Tooltip
    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if this.hasBuff then
            if this.lowTime then
                local threshold = BuffHelper:GetLowTimeThreshold(this.buffId)
                GameTooltip:SetText(this.spellName .. " - Less than " .. threshold .. "s left!", COLOR_YELLOW[1], COLOR_YELLOW[2], COLOR_YELLOW[3])
            else
                GameTooltip:SetText(this.spellName .. " - Active", COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3])
            end
        else
            if this.tracked then
                GameTooltip:SetText("Click to cast " .. this.spellName, COLOR_WHITE[1], COLOR_WHITE[2], COLOR_WHITE[3])
            else
                GameTooltip:SetText(this.spellName .. " - Not tracked", COLOR_PURPLE[1], COLOR_PURPLE[2], COLOR_PURPLE[3])
            end
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    btn.hasBuff = false
    return btn
end

-- Update button appearance based on buff status (hasBuff, lowTime = < 1 min left, tracked = buff is tracked for this member)
function BuffHelper:UpdateBuffButton(btn, hasBuff, lowTime, tracked)
    btn.hasBuff = hasBuff
    btn.lowTime = lowTime
    btn.tracked = tracked
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
        if tracked then
            -- Missing and tracked = red (needs buff)
            btn.icon:SetVertexColor(0.4, 0.4, 0.4, 1)
            btn.overlay:Show()
            btn.border:SetTexture(0.6, 0, 0, 1) -- Red border
        else
            -- Missing but not tracked = purple (doesn't need buff)
            btn.icon:SetVertexColor(0.5, 0.3, 0.6, 1)
            btn.overlay:Hide()
            btn.border:SetTexture(COLOR_PURPLE[1], COLOR_PURPLE[2], COLOR_PURPLE[3], 1) -- Purple border
        end
    end
end

-- Create the buff tracking panel
function BuffHelper:CreateBuffPanel()
    if mainFrame then return end

    local profile = self:GetActiveProfile()
    if not profile then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000BuffHelper|r: No buff profile found for your class!")
        return
    end

    local buffCount = table.getn(profile.buffs)
    local col1X = 8
    local colWidth = 25
    local baseWidth = 95 + (buffCount * colWidth)

    -- Main frame (1.12 style - no BackdropTemplate)
    mainFrame = CreateFrame("Frame", "BuffHelperPanel", UIParent)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetFrameLevel(10)
    mainFrame:SetWidth(baseWidth)
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
        BuffHelperDB.position = { point = point, relativePoint = relativePoint, x = xOfs, y = yOfs }
    end)

    -- Title (from profile)
    local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", mainFrame, "TOP", 0, -8)
    title:SetText(profile.title)
    title:SetTextColor(COLOR_HEADER[1], COLOR_HEADER[2], COLOR_HEADER[3], COLOR_HEADER[4])

    -- Close button
    local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 0, 0)
    closeBtn:SetWidth(20)
    closeBtn:SetHeight(20)
    closeBtn:SetScript("OnClick", function()
        mainFrame:Hide()
        BuffHelperDB.enabled = false
    end)

    -- Mode switch button
    modeButton = CreateFrame("Button", "BuffHelperModeBtn", mainFrame)
    modeButton:SetWidth(16)
    modeButton:SetHeight(14)
    modeButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 6, -7)

    modeButton.text = modeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modeButton.text:SetAllPoints(modeButton)
    modeButton.text:SetText("O")
    modeButton.text:SetTextColor(1, 0.82, 0, 1)

    modeButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

    modeButton:SetScript("OnClick", function()
        BuffHelper:ToggleMode()
    end)

    modeButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        if BuffHelperDB.mode == "config" then
            GameTooltip:SetText("Config Mode: Configure which buffs to track.\nClick to switch to Operational Mode.", 1, 1, 1)
        else
            GameTooltip:SetText("Operational Mode: Shows members needing buffs.\nClick to switch to Config Mode.", 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    modeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Create column headers dynamically from profile
    local buffStartX = 95
    for buffIdx, buffDef in ipairs(profile.buffs) do
        local colX = buffStartX + (buffIdx - 1) * colWidth
        local header = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", colX, -22)
        header:SetText(buffDef.headerText)
        header:SetTextColor(0.7, 0.7, 0.7, 1)
        header:Hide()
        columnHeaders[buffIdx] = header
    end

    -- Create threshold label (in name column, same row as inputs)
    local thresholdLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    thresholdLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col1X, -37)
    thresholdLabel:SetText("Alert (s):")
    thresholdLabel:SetTextColor(0.6, 0.6, 0.6, 1)
    thresholdLabel:Hide()
    mainFrame.thresholdLabel = thresholdLabel

    -- Create threshold input EditBoxes (below headers, only in config mode)
    for buffIdx, buffDef in ipairs(profile.buffs) do
        local colX = buffStartX + (buffIdx - 1) * colWidth

        local input = CreateFrame("EditBox", "BuffHelperThreshold"..buffDef.id, mainFrame)
        input:SetWidth(22)
        input:SetHeight(16)
        input:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", colX, -34)
        input:SetFontObject(GameFontNormalSmall)
        input:SetAutoFocus(false)
        input:SetNumeric(true)
        input:SetMaxLetters(3)
        input:SetTextInsets(2, 2, 0, 0)
        input:SetJustifyH("CENTER")

        -- Background
        input:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        input:SetBackdropColor(0, 0, 0, 0.8)
        input:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

        -- Set initial value from saved or default
        local threshold = self:GetLowTimeThreshold(buffDef.id)
        input:SetText(tostring(threshold))
        input.buffId = buffDef.id
        input.hasFocus = false

        -- Save on enter or focus lost
        input:SetScript("OnEnterPressed", function()
            local val = tonumber(this:GetText())
            if val and val > 0 then
                BuffHelper:SetLowTimeThreshold(this.buffId, val)
            else
                -- Reset to current value if invalid
                local current = BuffHelper:GetLowTimeThreshold(this.buffId)
                this:SetText(tostring(current))
            end
            this:ClearFocus()
        end)

        input:SetScript("OnEscapePressed", function()
            local current = BuffHelper:GetLowTimeThreshold(this.buffId)
            this:SetText(tostring(current))
            this:ClearFocus()
        end)

        input:SetScript("OnEditFocusGained", function()
            this.hasFocus = true
        end)

        input:SetScript("OnEditFocusLost", function()
            this.hasFocus = false
            local val = tonumber(this:GetText())
            if val and val > 0 then
                BuffHelper:SetLowTimeThreshold(this.buffId, val)
            else
                local current = BuffHelper:GetLowTimeThreshold(this.buffId)
                this:SetText(tostring(current))
            end
        end)

        input:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
            GameTooltip:SetText("Yellow warning threshold (seconds)", 1, 1, 1)
            GameTooltip:Show()
        end)

        input:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        input:Hide()
        thresholdInputs[buffIdx] = input
    end

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

        -- Create buff buttons and checkboxes dynamically from profile
        row.buffButtons = {}
        row.buffCheckboxes = {}

        for buffIdx, buffDef in ipairs(profile.buffs) do
            local colX = buffStartX + (buffIdx - 1) * colWidth

            -- Buff button
            local btn = self:CreateBuffButton(mainFrame, "BuffHelperBtn"..buffDef.id..i, colX, yPos, buffDef.spellName, buffDef.texture)
            btn:Hide()
            btn.buffId = buffDef.id
            btn.selfOnly = buffDef.selfOnly or false
            row.buffButtons[buffIdx] = btn

            -- Checkbox for config mode
            local cb = CreateFrame("CheckButton", "BuffHelperCb"..buffDef.id..i, mainFrame, "UICheckButtonTemplate")
            cb:SetWidth(20)
            cb:SetHeight(20)
            cb:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", colX, yPos)
            cb:SetChecked(true)
            cb:Hide()
            cb.rowIndex = i
            cb.buffId = buffDef.id
            cb.spellName = buffDef.spellName  -- Store for tooltip

            cb:SetScript("OnClick", function()
                local rowIdx = this.rowIndex
                local charName = memberRows[rowIdx].characterName
                if charName then
                    BuffHelper:SetBuffTracking(charName, this.buffId, this:GetChecked())
                end
            end)

            cb:SetScript("OnEnter", function()
                GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
                GameTooltip:SetText("Track " .. this.spellName, 1, 1, 1)
                GameTooltip:Show()
            end)

            cb:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            row.buffCheckboxes[buffIdx] = cb
        end

        row.unit = nil
        row.characterName = nil
        row.visible = false
        memberRows[i] = row
    end

    -- Restore saved position
    if BuffHelperDB and BuffHelperDB.position then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint(
            BuffHelperDB.position.point,
            UIParent,
            BuffHelperDB.position.relativePoint,
            BuffHelperDB.position.x,
            BuffHelperDB.position.y
        )
    end

    -- Always show initially (OnAddonLoaded will handle proper visibility)
    mainFrame:Show()
end

-- Clean up buff state for members who left the party
function BuffHelper:CleanupBuffState()
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
function BuffHelper:CheckBuffAndAlert(unit, name, buffType, hasBuff, timeLeft)
    if not name then return hasBuff end

    -- Get spell name from profile
    local buffDef = self:GetBuffDef(buffType)
    local spellName = buffDef and buffDef.spellName or buffType

    -- Initialize state for this unit if needed
    if not buffState[name] then
        buffState[name] = {}
    end

    local prevState = buffState[name][buffType]
    local threshold = self:GetLowTimeThreshold(buffType)
    local lowTime = timeLeft and timeLeft < threshold
    local lowKey = buffType .. "_lowAlert"
    local prevLowAlert = buffState[name][lowKey]

    -- Check if chat alerts are enabled for this buff
    local chatAlertEnabled = self:GetChatAlert(buffType)

    -- Alert if buff was lost (had it before, doesn't have it now)
    if prevState and not hasBuff and chatAlertEnabled then
        local numParty = GetNumPartyMembers()
        if numParty and numParty > 0 then
            SendChatMessage(name .. " needs " .. spellName .. "!", "PARTY")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BuffHelper]|r |cffff0000" .. name .. "|r needs |cff00ff00" .. spellName .. "|r!")
        end
    end

    -- Alert if less than threshold (once per drop below threshold)
    if hasBuff and lowTime and not prevLowAlert then
        if chatAlertEnabled then
            local sec = math.floor(timeLeft)
            DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BuffHelper]|r |cffffff00" .. name .. "|r: " .. spellName .. " has less than " .. threshold .. "s left (" .. sec .. "s)!")
        end
        buffState[name][lowKey] = true
    elseif not lowTime or not hasBuff then
        buffState[name][lowKey] = false
    end

    -- Save current state
    buffState[name][buffType] = hasBuff

    return hasBuff
end

-- Update the buff panel with current party status
function BuffHelper:UpdateBuffPanel()
    if not addonLoaded then return end
    if not mainFrame then return end
    if not BuffHelperDB or not BuffHelperDB.enabled then return end

    local profile = self:GetActiveProfile()
    if not profile then return end

    local isConfigMode = (BuffHelperDB.mode == "config")
    local buffCount = table.getn(profile.buffs)

    -- Calculate visible buffs for operational mode (buffs that need action)
    local visibleBuffs, visibleBuffIndexes = {}, {}
    if not isConfigMode then
        visibleBuffs = self:GetVisibleBuffsForOperationalMode()
        visibleBuffIndexes = self:GetVisibleBuffIndexes(visibleBuffs)
    end
    local visibleBuffCount = isConfigMode and buffCount or table.getn(visibleBuffIndexes)

    -- Adjust panel width dynamically based on visible columns
    local colWidth = 25
    mainFrame:SetWidth(95 + (visibleBuffCount * colWidth))

    -- Show/hide column headers, threshold label and inputs based on mode
    if mainFrame.thresholdLabel then
        if isConfigMode then
            mainFrame.thresholdLabel:Show()
        else
            mainFrame.thresholdLabel:Hide()
        end
    end

    for idx = 1, buffCount do
        if columnHeaders[idx] then
            if isConfigMode then
                columnHeaders[idx]:Show()
            else
                columnHeaders[idx]:Hide()
            end
        end
        if thresholdInputs[idx] then
            if isConfigMode then
                -- Only update value if input doesn't have focus (user not editing)
                if not thresholdInputs[idx].hasFocus then
                    local buffDef = profile.buffs[idx]
                    local threshold = self:GetLowTimeThreshold(buffDef.id)
                    thresholdInputs[idx]:SetText(tostring(threshold))
                end
                thresholdInputs[idx]:Show()
            else
                thresholdInputs[idx]:Hide()
            end
        end
    end

    -- Hide all rows first
    for i = 1, 5 do
        memberRows[i].name:SetText("")
        for idx = 1, buffCount do
            if memberRows[i].buffButtons[idx] then
                memberRows[i].buffButtons[idx]:Hide()
            end
            if memberRows[i].buffCheckboxes[idx] then
                memberRows[i].buffCheckboxes[idx]:Hide()
            end
        end
        memberRows[i].unit = nil
        memberRows[i].characterName = nil
        memberRows[i].visible = false
    end

    local rowIndex = 1

    -- Layout constants
    local col1X = 8
    local buffStartX = 95
    local colWidth = 25
    local rowHeight = 22
    local startY = isConfigMode and -52 or -22  -- Extra offset in config mode for headers + threshold inputs

    -- Helper function to display a member
    local function displayMember(unit, name)
        if not self:ShouldShowMember(unit, name) then
            return false
        end

        local row = memberRows[rowIndex]
        local yPos = startY - (rowIndex - 1) * rowHeight

        -- Reposition name
        row.name:ClearAllPoints()
        row.name:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", col1X, yPos - 5)

        local classColor = self:GetClassColor(unit)
        row.name:SetText(name)
        row.name:SetTextColor(classColor[1], classColor[2], classColor[3], classColor[4])
        row.unit = unit
        row.characterName = name

        local tracking = self:GetBuffTracking(name)

        if isConfigMode then
            -- Config mode: show checkboxes for all buffs, hide buttons
            for buffIdx, buffDef in ipairs(profile.buffs) do
                local colX = buffStartX + (buffIdx - 1) * colWidth

                if row.buffCheckboxes[buffIdx] then
                    row.buffCheckboxes[buffIdx]:ClearAllPoints()
                    row.buffCheckboxes[buffIdx]:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", colX, yPos)
                    row.buffCheckboxes[buffIdx]:SetChecked(tracking[buffDef.id])
                    row.buffCheckboxes[buffIdx]:Show()
                end
            end
        else
            -- Operational mode: show only visible buff columns (those needing action)
            for displayCol, buffIdx in ipairs(visibleBuffIndexes) do
                local buffDef = profile.buffs[buffIdx]
                local btn = row.buffButtons[buffIdx]
                if btn then
                    -- Position using display column index (0-based for X calculation)
                    local colX = buffStartX + (displayCol - 1) * colWidth
                    btn:ClearAllPoints()
                    btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", colX, yPos)

                    btn.unit = unit

                    local hasBuff, buffTime = self:HasBuff(unit, buffDef)

                    -- Only alert for tracked buffs
                    if tracking[buffDef.id] then
                        hasBuff = self:CheckBuffAndAlert(unit, name, buffDef.id, hasBuff, buffTime)
                    end

                    local threshold = self:GetLowTimeThreshold(buffDef.id)
                    local lowTime = buffTime and buffTime < threshold

                    self:UpdateBuffButton(btn, hasBuff, lowTime, tracking[buffDef.id])
                    btn:Show()
                end
            end
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
    local headerOffset = isConfigMode and 30 or 0  -- Extra space for headers + threshold inputs
    local newHeight = 28 + headerOffset + (visibleRows * 22)
    mainFrame:SetHeight(math.max(50, newHeight))
end

-- Called when addon is loaded
function BuffHelper:OnAddonLoaded()
    -- Initialize saved variables with defaults
    if not BuffHelperDB or not BuffHelperDB.initialized then
        BuffHelperDB = {
            initialized = true,
            enabled = true,
            position = nil,
            mode = "operational",
            buffTracking = {},
            lowTimeThresholds = {},
            chatAlerts = {},
        }
    end

    -- Migration: add new fields to existing DB
    if not BuffHelperDB.mode then
        BuffHelperDB.mode = "operational"
    end
    if not BuffHelperDB.buffTracking then
        BuffHelperDB.buffTracking = {}
    end
    if not BuffHelperDB.lowTimeThresholds then
        BuffHelperDB.lowTimeThresholds = {}
    end
    if not BuffHelperDB.chatAlerts then
        BuffHelperDB.chatAlerts = {}
    end

    -- Initialize addon components
    self:InitializeSlashCommands()
    self:CreateBuffPanel()

    addonLoaded = true

    -- Update mode button to match saved state
    self:UpdateModeButton()

    -- Force show the panel and update it
    if mainFrame then
        BuffHelperDB.enabled = true
        mainFrame:Show()
        self:UpdateBuffPanel()
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r loaded! Type /dbh for commands.")
end

-- Called when player logs in
function BuffHelper:OnPlayerLogin()
    if addonLoaded then
        self:UpdateBuffPanel()
    end
end

-- Initialize slash commands
function BuffHelper:InitializeSlashCommands()
    SLASH_DRUIDBUFFHELPER1 = "/druidbuffhelper"
    SLASH_DRUIDBUFFHELPER2 = "/dbh"
    
    SlashCmdList["DRUIDBUFFHELPER"] = function(msg)
        -- 1.12 style string parsing (no string:match)
        msg = msg or ""
        local command = string.lower(msg)

        -- Remove leading/trailing spaces
        command = string.gsub(command, "^%s*(.-)%s*$", "%1")

        if command == "help" then
            BuffHelper:PrintHelp()
        elseif command == "toggle" or command == "show" then
            BuffHelper:Toggle()
        elseif command == "hide" then
            BuffHelper:HidePanel()
        elseif command == "reset" then
            BuffHelper:ResetPosition()
        elseif command == "mode" then
            BuffHelper:ToggleMode()
        elseif command == "config" then
            BuffHelperDB.mode = "config"
            BuffHelper:UpdateModeButton()
            BuffHelper:UpdateBuffPanel()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r: Config mode - configure buff tracking")
        elseif command == "op" or command == "operational" then
            BuffHelperDB.mode = "operational"
            BuffHelper:UpdateModeButton()
            BuffHelper:UpdateBuffPanel()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r: Operational mode - showing members needing buffs")
        elseif command == "debug" then
            BuffHelper:DebugBuffs()
        else
            BuffHelper:Toggle()
        end
    end
end

-- Debug function to show buff return values
function BuffHelper:DebugBuffs()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper Debug|r - Player buffs (GetPlayerBuff API):")
    local i = 0
    while true do
        local buffIndex = GetPlayerBuff(i, "HELPFUL")
        if buffIndex < 0 then break end
        local texture = GetPlayerBuffTexture(buffIndex)
        local timeLeft = GetPlayerBuffTimeLeft(buffIndex)
        local info = string.format("Buff %d: index=%d, texture=%s, timeLeft=%s",
            i,
            buffIndex,
            tostring(texture),
            tostring(timeLeft))
        DEFAULT_CHAT_FRAME:AddMessage(info)
        i = i + 1
    end
    DEFAULT_CHAT_FRAME:AddMessage("GetTime() = " .. tostring(GetTime()))
end

-- Print help message
function BuffHelper:PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r commands:")
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
function BuffHelper:Toggle()
    if mainFrame then
        if mainFrame:IsShown() then
            mainFrame:Hide()
            BuffHelperDB.enabled = false
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r panel hidden")
        else
            mainFrame:Show()
            BuffHelperDB.enabled = true
            self:UpdateBuffPanel()
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r panel shown")
        end
    end
end

-- Hide panel
function BuffHelper:HidePanel()
    if mainFrame then
        mainFrame:Hide()
        BuffHelperDB.enabled = false
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r panel hidden")
    end
end

-- Reset panel position
function BuffHelper:ResetPosition()
    if mainFrame then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        BuffHelperDB.position = nil
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BuffHelper|r position reset")
    end
end

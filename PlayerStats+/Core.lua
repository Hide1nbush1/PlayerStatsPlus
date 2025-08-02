-- PlayerStats+ Addon (WotLK 3.3.5a)
local addonName, PlayerStats = ...

-- Ensure PlayerStats is available globally for modules
_G.PlayerStats = PlayerStats



-- Cache frequently used functions for performance
local format = string.format
local floor = math.floor
local min = math.min
local max = math.max
local time = time
local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitGUID = UnitGUID

-- Constants for better maintainability
local LINE_HEIGHT = 15
local TOP_PADDING = 1  -- Minimal padding for very tight frame
local BOTTOM_PADDING = 1  -- Minimal padding for very tight frame
local CLASS_SPACING = 5
local MIN_WIDTH = 90   -- Slightly larger minimum for readability
local MAX_WIDTH = 250  -- Increased maximum width for resizing
local MIN_HEIGHT = 50  -- Reasonable minimum height
local MIN_FONT_SCALE = 0.8  -- Slightly larger minimum font
local MAX_FONT_SCALE = 2.0  -- Allow much larger fonts

-- Default settings
PlayerStats.defaults = {
    x = 100,
    y = 100,
    width = 130,  -- Slightly larger default for better readability
    height = 90,  -- Slightly larger default height
    locked = false,
    fontScale = 1.0,
    showKills = true,
    showDeaths = true,
    showKDRatio = true,
    showPVP = true,
    showXP = true,
    kills = 0,
    deaths = 0,
    pvpKills = 0,
    pvpDeaths = 0,
    xp = 0,
    xpPerHour = 0,
    frameSize = "normal",  -- "small", "normal", "big"
    lastXP = 0,
    lastXPTime = 0,
    -- Session tracking
    sessionActive = false,
    sessionStartTime = 0,
    sessionKills = 0,
    sessionDeaths = 0,
    sessionPvpKills = 0,
    sessionPvpDeaths = 0,
    sessionStartXP = 0,
    sessionXP = 0,
    savedSessions = {}
}

-- Initialize SavedVariables with better error handling
local function InitializeSavedVariables()
    if not PlayerStatsDB then
        PlayerStatsDB = {}
    end
    
    -- Ensure all default values exist
    for k, v in pairs(PlayerStats.defaults) do
        if PlayerStatsDB[k] == nil then
            PlayerStatsDB[k] = v
        end
    end
    
    -- Validate critical values
    if not PlayerStatsDB.point then
        PlayerStatsDB.point = "CENTER"
        PlayerStatsDB.relativePoint = "CENTER"
        PlayerStatsDB.posX = PlayerStatsDB.x or 100
        PlayerStatsDB.posY = PlayerStatsDB.y or 100
    end
end

-- Call initialization immediately
InitializeSavedVariables()

-- Performance throttling is now handled in Statistics module

-- Class colors
local CLASS_COLORS = {
    ["WARRIOR"]     = { r = 0.78, g = 0.61, b = 0.43 },
    ["PALADIN"]     = { r = 0.96, g = 0.55, b = 0.73 },
    ["HUNTER"]      = { r = 0.67, g = 0.83, b = 0.45 },
    ["ROGUE"]       = { r = 1.00, g = 0.96, b = 0.41 },
    ["PRIEST"]      = { r = 1.00, g = 1.00, b = 1.00 },
    ["DEATHKNIGHT"] = { r = 0.77, g = 0.12, b = 0.23 },
    ["SHAMAN"]      = { r = 0.00, g = 0.44, b = 0.87 },
    ["MAGE"]        = { r = 0.41, g = 0.80, b = 0.94 },
    ["WARLOCK"]     = { r = 0.58, g = 0.51, b = 0.79 },
    ["DRUID"]       = { r = 1.00, g = 0.49, b = 0.04 },
}

-- Create main frame
function PlayerStats:CreateFrame()
    
    local frame = CreateFrame("Frame", "PlayerStats_MainFrame", UIParent)
    
    -- Calculate initial height based on visible content
    local visibleElements = 1 -- Always show name (level is on same line)
    if PlayerStatsDB.showKills then visibleElements = visibleElements + 1 end
    if PlayerStatsDB.showDeaths then visibleElements = visibleElements + 1 end
    if PlayerStatsDB.showKDRatio then visibleElements = visibleElements + 1 end
    if PlayerStatsDB.showPVP then visibleElements = visibleElements + 2 end -- PVP Kills + PVP Deaths
    if PlayerStatsDB.showXP then visibleElements = visibleElements + 2 end -- XP + XP/Hr
    
    local contentHeight = visibleElements * LINE_HEIGHT + TOP_PADDING + BOTTOM_PADDING
    local initialHeight = max(contentHeight, MIN_HEIGHT, PlayerStatsDB.height or 90)
    
    -- Use stored width but ensure it's within reasonable bounds
    local frameWidth = max(PlayerStatsDB.width or 130, MIN_WIDTH)
    
    frame:SetSize(frameWidth, initialHeight)
    frame:SetPoint(PlayerStatsDB.point, UIParent, PlayerStatsDB.relativePoint, PlayerStatsDB.posX, PlayerStatsDB.posY)
    frame:SetMovable(true)
    frame:SetResizable(false)  -- Static frame - no manual resizing
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    
    -- No backdrop by default - only show during interaction
    frame:SetBackdrop(nil)
    frame:RegisterForDrag("LeftButton")
    frame.locked = PlayerStatsDB.locked

    -- Name text
    frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.nameText:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.nameText:SetJustifyH("CENTER")
    frame.nameText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    
    -- Level text (separate from name for custom color)
    frame.levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.levelText:SetPoint("TOPLEFT", frame.nameText, "TOPRIGHT", 2, 0)
    frame.levelText:SetJustifyH("LEFT")
    frame.levelText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")



    -- Kills text
    frame.killsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.killsText:SetPoint("TOP", frame, "TOP", 0, -20)
    frame.killsText:SetJustifyH("CENTER")
    frame.killsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- Deaths text
    frame.deathsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.deathsText:SetPoint("TOP", frame, "TOP", 0, -35)
    frame.deathsText:SetJustifyH("CENTER")
    frame.deathsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- K/D Ratio text
    frame.kdRatioText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.kdRatioText:SetPoint("TOP", frame, "TOP", 0, -50)
    frame.kdRatioText:SetJustifyH("CENTER")
    frame.kdRatioText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- PVP Kills text
    frame.pvpKillsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.pvpKillsText:SetPoint("TOP", frame, "TOP", 0, -65)
    frame.pvpKillsText:SetJustifyH("CENTER")
    frame.pvpKillsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- PVP Deaths text
    frame.pvpDeathsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.pvpDeathsText:SetPoint("TOP", frame, "TOP", 0, -80)
    frame.pvpDeathsText:SetJustifyH("CENTER")
    frame.pvpDeathsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- XP text
    frame.xpText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.xpText:SetPoint("TOP", frame, "TOP", 0, -95)
    frame.xpText:SetJustifyH("CENTER")
    frame.xpText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- XP per Hour text
    frame.xpPerHourText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.xpPerHourText:SetPoint("TOP", frame, "TOP", 0, -110)
    frame.xpPerHourText:SetJustifyH("CENTER")
    frame.xpPerHourText:SetFont("Fonts\\FRIZQT__.TTF", 10 * PlayerStatsDB.fontScale, "OUTLINE")

    -- Update player info
    local function UpdatePlayerInfo()
        local name = UnitName("player")
        local level = UnitLevel("player")
        local class = select(2, UnitClass("player"))
        local color = CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }

        -- Update name and level
        frame.nameText:SetText(name)
        frame.levelText:SetText(format("(%d)", level))
        frame.levelText:SetTextColor(0.49, 0.04, 1.00) -- DB2CE6 purple for level
        
        -- Set name color to class color
        frame.nameText:SetTextColor(color.r, color.g, color.b)
        
        -- Helper function to update text elements
        local function UpdateTextElement(textElement, showSetting, formatString, value, color)
            if showSetting then
                textElement:SetText(format(formatString, value or 0))
                textElement:SetTextColor(color.r, color.g, color.b)
            else
                textElement:SetText("")
            end
        end
        
        -- Update kills and deaths
        UpdateTextElement(frame.killsText, PlayerStatsDB.showKills, "Kills: %d", PlayerStatsDB.kills, {r = 0.2, g = 1.0, b = 0.2})
        UpdateTextElement(frame.deathsText, PlayerStatsDB.showDeaths, "Deaths: %d", PlayerStatsDB.deaths, {r = 1.0, g = 0.2, b = 0.2})

        -- Update K/D Ratio
        if PlayerStatsDB.showKDRatio then
            local pvpKills = PlayerStatsDB.pvpKills or 0
            local pvpDeaths = PlayerStatsDB.pvpDeaths or 0
            local kdRatio = pvpDeaths > 0 and (pvpKills / pvpDeaths) or pvpKills
            frame.kdRatioText:SetText(format("PVP K/D: %.2f", kdRatio))
            frame.kdRatioText:SetTextColor(1.0, 1.0, 0.0)
        else
            frame.kdRatioText:SetText("")
        end

        -- Update PVP stats
        if PlayerStatsDB.showPVP then
            frame.pvpKillsText:SetText(format("PVP Kills: %d", PlayerStatsDB.pvpKills or 0))
            frame.pvpKillsText:SetTextColor(0.0, 1.0, 1.0)
            frame.pvpDeathsText:SetText(format("PVP Deaths: %d", PlayerStatsDB.pvpDeaths or 0))
            frame.pvpDeathsText:SetTextColor(1.0, 0.5, 0.0)
        else
            frame.pvpKillsText:SetText("")
            frame.pvpDeathsText:SetText("")
        end

        -- Update XP display
        if PlayerStatsDB.showXP then
            local currentXP = UnitXP("player")
            local totalXP = UnitXPMax("player")
            
            frame.xpText:SetText(format("XP: %d/%d", currentXP, totalXP))
            frame.xpText:SetTextColor(0.91, 0.45, 0.95) -- E874F2 pink color for XP
            
            local xpPerHour = PlayerStatsDB.xpPerHour or 0
            frame.xpPerHourText:SetText(format("XP/Hr: %.0f", xpPerHour))
            frame.xpPerHourText:SetTextColor(0.91, 0.45, 0.95) -- E874F2 pink color for XP per hour
        else
            frame.xpText:SetText("")
            frame.xpPerHourText:SetText("")
        end
    end

    -- Movement and sizing
    frame:SetScript("OnDragStart", function(self)
        if not self.locked then
            self:StartMoving()
            -- Show backdrop only during move
            self:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                tile = true,
                tileSize = 16,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            self:SetBackdropColor(0, 0, 0, 0.8)
        end
    end)

    frame:SetScript("OnDragStop", function(self)
        if not self.locked then
            self:StopMovingOrSizing()
            -- Remove backdrop when done moving
            self:SetBackdrop(nil)
            PlayerStats:SavePosition()
        end
    end)

    -- No resize scripts needed - static frame

    UpdatePlayerInfo()
    PlayerStats.MainFrame = frame
    
    -- Apply lock state after frame creation
    self:SetLocked(PlayerStatsDB.locked)
    
    -- Apply saved font size if available
    if PlayerStatsDB.frameSize then
        self:ApplyFontSize(PlayerStatsDB.frameSize)
    end
    
    return frame
end

-- Frame control functions
function PlayerStats:SavePosition()
    if self.MainFrame then
        local point, _, relativePoint, x, y = self.MainFrame:GetPoint()
        PlayerStatsDB.point = point
        PlayerStatsDB.relativePoint = relativePoint
        PlayerStatsDB.posX = x
        PlayerStatsDB.posY = y
        -- Force save after position change
        self:SaveAllSettings()
    end
end

function PlayerStats:SaveAllSettings()
    -- Force save all settings to disk
    if PlayerStatsDB then
        -- This ensures the variables are marked as changed
        PlayerStatsDB.lastSaved = time()
        -- Mark the table as modified to ensure it gets saved
        PlayerStatsDB._version = (PlayerStatsDB._version or 0) + 1
    end
end

function PlayerStats:SetLocked(state)
    PlayerStatsDB.locked = state
    if self.MainFrame then
        self.MainFrame.locked = state
        if state then
            -- Stop any current movement/sizing when locking
            self.MainFrame:StopMovingOrSizing()
            self.MainFrame:SetBackdrop(nil)
        end
    end
    -- Force save after changing lock state
    self:SaveAllSettings()
end

-- Apply predefined font sizes
function PlayerStats:ApplyFontSize(size)
    if not self.MainFrame then return end
    
    local fontScale
    
    if size == "small" then
        fontScale = 0.8  -- Smaller text
    elseif size == "big" then  
        fontScale = 1.4  -- Bigger text
    else -- "normal" or default
        fontScale = 1.0  -- Normal text
    end
    
    -- Update saved settings
    PlayerStatsDB.fontScale = fontScale
    PlayerStatsDB.frameSize = size  -- Keep for compatibility
    
    -- Update all font sizes
    self.MainFrame.nameText:SetFont("Fonts\\FRIZQT__.TTF", 12 * fontScale, "OUTLINE")
    self.MainFrame.levelText:SetFont("Fonts\\FRIZQT__.TTF", 12 * fontScale, "OUTLINE")
    self.MainFrame.killsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    self.MainFrame.deathsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    self.MainFrame.kdRatioText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    self.MainFrame.pvpKillsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    self.MainFrame.pvpDeathsText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    self.MainFrame.xpText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    self.MainFrame.xpPerHourText:SetFont("Fonts\\FRIZQT__.TTF", 10 * fontScale, "OUTLINE")
    
    -- Auto-resize frame to fit new text size
    self:AutoResizeFrame()
    
    -- Update display and reposition elements
    self:RepositionTextElements()
end

-- Auto-resize frame based on content and font scale
function PlayerStats:AutoResizeFrame()
    if not self.MainFrame then return end
    
    local fontScale = PlayerStatsDB.fontScale or 1.0
    
    -- Count visible lines
    local visibleLines = 1 -- Name + Level (same line)
    if PlayerStatsDB.showKills then visibleLines = visibleLines + 1 end
    if PlayerStatsDB.showDeaths then visibleLines = visibleLines + 1 end
    if PlayerStatsDB.showKDRatio then visibleLines = visibleLines + 1 end
    if PlayerStatsDB.showPVP then visibleLines = visibleLines + 2 end
    if PlayerStatsDB.showXP then visibleLines = visibleLines + 2 end
    
    -- Calculate dimensions based on font scale
    local lineHeight = LINE_HEIGHT * fontScale
    local width = math.max(MIN_WIDTH, 120 * fontScale)  -- Minimum width scales with font
    local height = (visibleLines * lineHeight) + TOP_PADDING + BOTTOM_PADDING
    
    -- Update frame size
    self.MainFrame:SetSize(width, height)
    PlayerStatsDB.width = width
    PlayerStatsDB.height = height
end

function PlayerStats:ToggleFrame(show)
    PlayerStatsDB.showFrame = show
    if show and not self.MainFrame then
        self:CreateFrame()
    elseif self.MainFrame then
        self.MainFrame:SetShown(show)
    end
end

function PlayerStats:RepositionTextElements()
    if self.MainFrame then
        local frame = self.MainFrame
        local lineHeight = LINE_HEIGHT * PlayerStatsDB.fontScale
        local currentY = -5
        
        -- Name and level stay at top
        frame.nameText:SetPoint("TOP", frame, "TOP", 0, currentY)
        frame.levelText:SetPoint("TOPLEFT", frame.nameText, "TOPRIGHT", 2, 0)
        
        currentY = currentY - lineHeight
        
        -- Kills
        if PlayerStatsDB.showKills then
            frame.killsText:SetPoint("TOP", frame, "TOP", 0, currentY)
            currentY = currentY - lineHeight
        end
        
        -- Deaths
        if PlayerStatsDB.showDeaths then
            frame.deathsText:SetPoint("TOP", frame, "TOP", 0, currentY)
            currentY = currentY - lineHeight
        end
        
        -- K/D Ratio
        if PlayerStatsDB.showKDRatio then
            frame.kdRatioText:SetPoint("TOP", frame, "TOP", 0, currentY)
            currentY = currentY - lineHeight
        end
        
        -- PVP Kills
        if PlayerStatsDB.showPVP then
            frame.pvpKillsText:SetPoint("TOP", frame, "TOP", 0, currentY)
            currentY = currentY - lineHeight
        end
        
        -- PVP Deaths
        if PlayerStatsDB.showPVP then
            frame.pvpDeathsText:SetPoint("TOP", frame, "TOP", 0, currentY)
            currentY = currentY - lineHeight
        end
        
        -- XP
        if PlayerStatsDB.showXP then
            frame.xpText:SetPoint("TOP", frame, "TOP", 0, currentY)
            currentY = currentY - lineHeight
        end
        
        -- XP per Hour
        if PlayerStatsDB.showXP then
            frame.xpPerHourText:SetPoint("TOP", frame, "TOP", 0, currentY)
        end
        
        -- Update frame height to match content
        local contentHeight = TOP_PADDING + lineHeight -- Name line (level is on same line)
        if PlayerStatsDB.showKills then contentHeight = contentHeight + lineHeight end
        if PlayerStatsDB.showDeaths then contentHeight = contentHeight + lineHeight end
        if PlayerStatsDB.showKDRatio then contentHeight = contentHeight + lineHeight end
        if PlayerStatsDB.showPVP then contentHeight = contentHeight + lineHeight end -- PVP Kills
        if PlayerStatsDB.showPVP then contentHeight = contentHeight + lineHeight end -- PVP Deaths
        if PlayerStatsDB.showXP then contentHeight = contentHeight + lineHeight end -- XP
        if PlayerStatsDB.showXP then contentHeight = contentHeight + lineHeight end -- XP/Hr
        contentHeight = contentHeight + BOTTOM_PADDING
        
        -- Ensure minimum height for resizing capability
        contentHeight = max(contentHeight, MIN_HEIGHT)
        
        -- Don't automatically resize - let user control frame size
        -- frame:SetHeight(contentHeight)
        -- PlayerStatsDB.height = contentHeight
    end
end

-- Session management functions
-- Session functions moved to Sessions.lua module



function PlayerStats:UpdateDisplay()
    if self.MainFrame then
        local name = UnitName("player")
        local level = UnitLevel("player")
        local class = select(2, UnitClass("player"))
        local color = CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }

        self.MainFrame.nameText:SetText(name)
        self.MainFrame.levelText:SetText(format("(%d)", level))
        self.MainFrame.levelText:SetTextColor(0.49, 0.04, 1.00) -- DB2CE6 purple for level
        
        -- Set name color to class color
        self.MainFrame.nameText:SetTextColor(color.r, color.g, color.b)
        
        -- Update kills and deaths display
        if PlayerStatsDB.showKills then
            self.MainFrame.killsText:SetText(format("Kills: %d", PlayerStatsDB.kills or 0))
            self.MainFrame.killsText:SetTextColor(0.2, 1.0, 0.2) -- Green color for kills
        else
            self.MainFrame.killsText:SetText("")
        end
        
        if PlayerStatsDB.showDeaths then
            self.MainFrame.deathsText:SetText(format("Deaths: %d", PlayerStatsDB.deaths or 0))
            self.MainFrame.deathsText:SetTextColor(1.0, 0.2, 0.2) -- Red color for deaths
        else
            self.MainFrame.deathsText:SetText("")
        end

        -- Update K/D Ratio display
        if PlayerStatsDB.showKDRatio then
            local pvpKills = PlayerStatsDB.pvpKills or 0
            local pvpDeaths = PlayerStatsDB.pvpDeaths or 0
            local kdRatio = pvpDeaths > 0 and (pvpKills / pvpDeaths) or pvpKills
            self.MainFrame.kdRatioText:SetText(format("PVP K/D: %.2f", kdRatio))
            self.MainFrame.kdRatioText:SetTextColor(1.0, 1.0, 0.0) -- Yellow color for K/D ratio
        else
            self.MainFrame.kdRatioText:SetText("")
        end

        -- Update PVP stats display
        if PlayerStatsDB.showPVP then
            self.MainFrame.pvpKillsText:SetText(format("PVP Kills: %d", PlayerStatsDB.pvpKills or 0))
            self.MainFrame.pvpKillsText:SetTextColor(0.0, 1.0, 1.0) -- Cyan color for PVP kills
            self.MainFrame.pvpDeathsText:SetText(format("PVP Deaths: %d", PlayerStatsDB.pvpDeaths or 0))
            self.MainFrame.pvpDeathsText:SetTextColor(1.0, 0.5, 0.0) -- Orange color for PVP deaths
        else
            self.MainFrame.pvpKillsText:SetText("")
            self.MainFrame.pvpDeathsText:SetText("")
        end

        -- Update XP display
        if PlayerStatsDB.showXP then
            local currentXP = UnitXP("player")
            local totalXP = UnitXPMax("player")
            
            self.MainFrame.xpText:SetText(format("XP: %d/%d", currentXP, totalXP))
            self.MainFrame.xpText:SetTextColor(0.91, 0.45, 0.95) -- E874F2 pink color for XP
            
            -- Display XP per hour
            local xpPerHour = PlayerStatsDB.xpPerHour or 0
            self.MainFrame.xpPerHourText:SetText(format("XP/Hr: %.0f", xpPerHour))
            self.MainFrame.xpPerHourText:SetTextColor(0.91, 0.45, 0.95) -- E874F2 pink color for XP per hour
        else
            self.MainFrame.xpText:SetText("")
            self.MainFrame.xpPerHourText:SetText("")
        end
        
        -- Auto-resize frame and reposition text elements after updating content
        self:AutoResizeFrame()
        self:RepositionTextElements()
    end
end



-- Initialize
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Player enters combat
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Player leaves combat
eventFrame:RegisterEvent("PLAYER_XP_UPDATE")



eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Initialize XP tracking via Statistics module
        if PlayerStats.Statistics then
            PlayerStats.Statistics:InitializeXP()
        end
        
        PlayerStats:CreateFrame()
        PlayerStats:UpdateDisplay()
    elseif event == "PLAYER_LOGOUT" then
        -- Force save all settings before logout
        if PlayerStats then
            PlayerStats:SaveAllSettings()
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Delegate to Statistics module
        if PlayerStats.Statistics then
            PlayerStats.Statistics:HandleCombatLogEvent(...)
        end
    elseif event == "PLAYER_DEAD" then
        -- Delegate to Statistics module
        if PlayerStats.Statistics then
            PlayerStats.Statistics:HandlePlayerDeath()
        end
    elseif event == "PLAYER_XP_UPDATE" then
        -- Delegate to Statistics module
        if PlayerStats.Statistics then
            PlayerStats.Statistics:HandleXPUpdate()
        end
    end
end)

-- Utility commands
SLASH_PLAYERSTATS_UTILS1 = "/psutil"
SlashCmdList["PLAYERSTATS_UTILS"] = function(msg)
    -- Ensure Utils module exists
    if not PlayerStats.Utils then
        return
    end
    PlayerStats.Utils:HandleCommand(msg)
end
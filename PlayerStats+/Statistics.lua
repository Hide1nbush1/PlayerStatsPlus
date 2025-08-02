-- Statistics.lua - Statistics Management Module for PlayerStats+
local addonName, PlayerStats = ...

-- Create PlayerStats table if it doesn't exist
if not PlayerStats then
    PlayerStats = _G.PlayerStats or {}
    _G.PlayerStats = PlayerStats
end

-- Create Statistics module
PlayerStats.Statistics = PlayerStats.Statistics or {}
local Statistics = PlayerStats.Statistics

-- Cache frequently used functions
local format = string.format
local floor = math.floor
local time = time
local UnitXP = UnitXP
local UnitName = UnitName

-- Performance throttling
local lastUpdateTime = 0
local UPDATE_THROTTLE = 0.1 -- Update at most 10 times per second

-- Throttled update and save function
function Statistics:UpdateAndSave()
    local currentTime = time()
    if currentTime - lastUpdateTime >= UPDATE_THROTTLE then
        -- Update display
        if PlayerStats.UpdateDisplay then
            PlayerStats:UpdateDisplay()
        end
        
        -- Save settings
        if PlayerStats.SaveAllSettings then
            PlayerStats:SaveAllSettings()
        end
        
        lastUpdateTime = currentTime
    end
end

-- PVP detection helper function
function Statistics:IsPlayerTarget(destName, destFlags)
    local isPlayerTarget = false
    
    -- Method 1: Try bit operation if available
    if bit and destFlags and destFlags > 0 then
        isPlayerTarget = bit.band(destFlags, 0x400) > 0
    end
    
    -- Method 2: Try UnitIsPlayer as fallback
    if not isPlayerTarget and destName and destName ~= "" then
        isPlayerTarget = UnitIsPlayer(destName) == 1
    end
    
    -- Method 3: Simple heuristic - player names are usually capitalized and don't contain certain patterns
    if not isPlayerTarget and destName and destName ~= "" then
        local firstChar = string.sub(destName, 1, 1)
        local hasNumbers = string.find(destName, "%d")
        local hasSpaces = string.find(destName, " ")
        -- Most player names start with capital letter, no numbers, no spaces, and reasonable length
        isPlayerTarget = firstChar == string.upper(firstChar) and not hasNumbers and not hasSpaces and string.len(destName) > 2 and string.len(destName) < 13
    end
    
    return isPlayerTarget
end

-- Statistics tracking functions
function Statistics:RecordKill(isPvp)
    -- Update total kills
    PlayerStatsDB.kills = (PlayerStatsDB.kills or 0) + 1
    
    if isPvp then
        PlayerStatsDB.pvpKills = (PlayerStatsDB.pvpKills or 0) + 1
    end
    
    -- Update session stats via Sessions module
    if PlayerStats.Sessions then
        PlayerStats.Sessions:UpdateSessionKill(isPvp)
    end
    
    -- Update display and save settings
    self:UpdateAndSave()
end

function Statistics:RecordDeath(isPvp)
    -- Update total deaths
    PlayerStatsDB.deaths = (PlayerStatsDB.deaths or 0) + 1
    
    if isPvp then
        PlayerStatsDB.pvpDeaths = (PlayerStatsDB.pvpDeaths or 0) + 1
    end
    
    -- Update session stats via Sessions module
    if PlayerStats.Sessions then
        PlayerStats.Sessions:UpdateSessionDeath(isPvp)
    end
    
    -- Update display and save settings
    self:UpdateAndSave()
end

function Statistics:RecordXPGain(xpGain)
    if xpGain and xpGain > 0 then
        PlayerStatsDB.xp = (PlayerStatsDB.xp or 0) + xpGain
        
        -- Update session XP via Sessions module
        if PlayerStats.Sessions then
            PlayerStats.Sessions:UpdateSessionXP(xpGain)
        end
        
        -- Calculate XP per hour
        local currentTime = time()
        if PlayerStatsDB.lastXPTime and PlayerStatsDB.lastXPTime > 0 then
            local timeDiff = currentTime - PlayerStatsDB.lastXPTime
            if timeDiff > 0 then
                local hourlyRate = (xpGain / timeDiff) * 3600
                -- Smooth the XP/hour calculation
                if PlayerStatsDB.xpPerHour and PlayerStatsDB.xpPerHour > 0 then
                    PlayerStatsDB.xpPerHour = (PlayerStatsDB.xpPerHour * 0.7) + (hourlyRate * 0.3)
                else
                    PlayerStatsDB.xpPerHour = hourlyRate
                end
            end
        end
        
        PlayerStatsDB.lastXP = UnitXP("player")
        PlayerStatsDB.lastXPTime = currentTime
        
        -- Update display and save settings
        self:UpdateAndSave()
    end
end

-- Handle combat log events
function Statistics:HandleCombatLogEvent(timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool)
    if eventType == "PARTY_KILL" then
        local playerName = UnitName("player")
        -- Check if the player caused the kill
        if sourceName and sourceName == playerName then
            local isPvp = self:IsPlayerTarget(destName, destFlags)
            self:RecordKill(isPvp)
        end
    end
end

-- Handle player death event
function Statistics:HandlePlayerDeath()
    local isPvp = UnitIsPVP("player") == 1
    self:RecordDeath(isPvp)
end

-- Handle XP update event
function Statistics:HandleXPUpdate()
    local currentXP = UnitXP("player")
    local currentTime = time()
    
    -- Calculate XP gained
    local xpGained = currentXP - PlayerStatsDB.lastXP
    if xpGained > 0 then
        self:RecordXPGain(xpGained)
    end
    
    -- Update stored values
    PlayerStatsDB.xp = currentXP
    PlayerStatsDB.lastXP = currentXP
    PlayerStatsDB.lastXPTime = currentTime
end

-- Initialize XP tracking
function Statistics:InitializeXP()
    PlayerStatsDB.xp = UnitXP("player")
    PlayerStatsDB.lastXP = UnitXP("player")
    PlayerStatsDB.lastXPTime = time()
end

-- Get statistics summary
function Statistics:GetSummary()
    return {
        kills = PlayerStatsDB.kills or 0,
        deaths = PlayerStatsDB.deaths or 0,
        pvpKills = PlayerStatsDB.pvpKills or 0,
        pvpDeaths = PlayerStatsDB.pvpDeaths or 0,
        kdRatio = (PlayerStatsDB.deaths and PlayerStatsDB.deaths > 0) and 
                  (PlayerStatsDB.kills / PlayerStatsDB.deaths) or 
                  (PlayerStatsDB.kills or 0),
        pvpKdRatio = (PlayerStatsDB.pvpDeaths and PlayerStatsDB.pvpDeaths > 0) and 
                     (PlayerStatsDB.pvpKills / PlayerStatsDB.pvpDeaths) or 
                     (PlayerStatsDB.pvpKills or 0),
        xpGained = PlayerStatsDB.xp or 0,
        xpPerHour = PlayerStatsDB.xpPerHour or 0
    }
end

-- Reset all statistics
function Statistics:Reset()
    PlayerStatsDB.kills = 0
    PlayerStatsDB.deaths = 0
    PlayerStatsDB.pvpKills = 0
    PlayerStatsDB.pvpDeaths = 0
    PlayerStatsDB.xp = 0
    PlayerStatsDB.xpPerHour = 0
    PlayerStatsDB.lastXP = 0
    PlayerStatsDB.lastXPTime = 0
    
    print("PlayerStats+ All statistics reset!")
    
    if PlayerStats.UpdateDisplay then
        PlayerStats:UpdateDisplay()
    end
end
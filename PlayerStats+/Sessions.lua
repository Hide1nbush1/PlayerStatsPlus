-- Sessions.lua - Session Management Module for PlayerStats+
local addonName, PlayerStats = ...

-- Create PlayerStats table if it doesn't exist
if not PlayerStats then
    PlayerStats = _G.PlayerStats or {}
    _G.PlayerStats = PlayerStats
end

-- Create Sessions module
PlayerStats.Sessions = PlayerStats.Sessions or {}
local Sessions = PlayerStats.Sessions

-- Cache frequently used functions
local format = string.format
local floor = math.floor
local time = time

-- Session-related functionality
function Sessions:StartSession()
    if not PlayerStatsDB.sessionActive then
        PlayerStatsDB.sessionActive = true
        PlayerStatsDB.sessionStartTime = time()
        PlayerStatsDB.sessionKills = 0
        PlayerStatsDB.sessionDeaths = 0
        PlayerStatsDB.sessionPvpKills = 0
        PlayerStatsDB.sessionPvpDeaths = 0
        PlayerStatsDB.sessionStartXP = UnitXP("player")
        PlayerStatsDB.sessionXP = 0
        
        print("PlayerStats+ Session started!")
        PlayerStats:SaveAllSettings()
    end
end

function Sessions:StopSession()
    if PlayerStatsDB.sessionActive then
        local sessionDuration = time() - PlayerStatsDB.sessionStartTime
        local sessionData = {
            startTime = PlayerStatsDB.sessionStartTime,
            endTime = time(),
            duration = sessionDuration,
            kills = PlayerStatsDB.sessionKills,
            deaths = PlayerStatsDB.sessionDeaths,
            pvpKills = PlayerStatsDB.sessionPvpKills,
            pvpDeaths = PlayerStatsDB.sessionPvpDeaths,
            xpGained = PlayerStatsDB.sessionXP,
            kdRatio = PlayerStatsDB.sessionDeaths > 0 and (PlayerStatsDB.sessionKills / PlayerStatsDB.sessionDeaths) or PlayerStatsDB.sessionKills,
            pvpKdRatio = PlayerStatsDB.sessionPvpDeaths > 0 and (PlayerStatsDB.sessionPvpKills / PlayerStatsDB.sessionPvpDeaths) or PlayerStatsDB.sessionPvpKills
        }
        
        -- Add to saved sessions
        if not PlayerStatsDB.savedSessions then
            PlayerStatsDB.savedSessions = {}
        end
        table.insert(PlayerStatsDB.savedSessions, sessionData)
        
        -- Reset session
        PlayerStatsDB.sessionActive = false
        PlayerStatsDB.sessionStartTime = 0
        PlayerStatsDB.sessionKills = 0
        PlayerStatsDB.sessionDeaths = 0
        PlayerStatsDB.sessionPvpKills = 0
        PlayerStatsDB.sessionPvpDeaths = 0
        PlayerStatsDB.sessionStartXP = 0
        PlayerStatsDB.sessionXP = 0
        
        print("PlayerStats+ Session ended!")
        print(format("Session Summary: %d kills, %d deaths, %d PVP kills, %d PVP deaths, %d XP gained", 
            sessionData.kills, sessionData.deaths, sessionData.pvpKills, sessionData.pvpDeaths, sessionData.xpGained))
        
        PlayerStats:SaveAllSettings()
    end
end

function Sessions:GetSessionStatus()
    if PlayerStatsDB.sessionActive then
        local duration = time() - PlayerStatsDB.sessionStartTime
        local hours = floor(duration / 3600)
        local minutes = floor((duration % 3600) / 60)
        local seconds = duration % 60
        
        return {
            active = true,
            duration = format("%02d:%02d:%02d", hours, minutes, seconds),
            kills = PlayerStatsDB.sessionKills,
            deaths = PlayerStatsDB.sessionDeaths,
            pvpKills = PlayerStatsDB.sessionPvpKills,
            pvpDeaths = PlayerStatsDB.sessionPvpDeaths,
            xpGained = PlayerStatsDB.sessionXP
        }
    else
        return { active = false }
    end
end

function Sessions:GetSavedSessions()
    return PlayerStatsDB.savedSessions or {}
end

function Sessions:ClearSavedSessions()
    PlayerStatsDB.savedSessions = {}
    PlayerStats:SaveAllSettings()

end

-- Update session stats when kills/deaths occur
function Sessions:UpdateSessionKill(isPvp)
    if PlayerStatsDB.sessionActive then
        PlayerStatsDB.sessionKills = (PlayerStatsDB.sessionKills or 0) + 1
        if isPvp then
            PlayerStatsDB.sessionPvpKills = (PlayerStatsDB.sessionPvpKills or 0) + 1
        end
    end
end

function Sessions:UpdateSessionDeath(isPvp)
    if PlayerStatsDB.sessionActive then
        PlayerStatsDB.sessionDeaths = (PlayerStatsDB.sessionDeaths or 0) + 1
        if isPvp then
            PlayerStatsDB.sessionPvpDeaths = (PlayerStatsDB.sessionPvpDeaths or 0) + 1
        end
    end
end

function Sessions:UpdateSessionXP(xpGain)
    if PlayerStatsDB.sessionActive and xpGain > 0 then
        PlayerStatsDB.sessionXP = (PlayerStatsDB.sessionXP or 0) + xpGain
    end
end

-- Convenience functions for backward compatibility
function PlayerStats:StartSession()
    return self.Sessions:StartSession()
end

function PlayerStats:StopSession()
    return self.Sessions:StopSession()
end

function PlayerStats:GetSessionStatus()
    return self.Sessions:GetSessionStatus()
end

function PlayerStats:GetSavedSessions()
    return self.Sessions:GetSavedSessions()
end

function PlayerStats:ClearSavedSessions()
    return self.Sessions:ClearSavedSessions()
end
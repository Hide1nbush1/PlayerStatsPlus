-- Utils.lua - Utility Commands Module for PlayerStats+
local addonName, PlayerStats = ...

-- Create PlayerStats table if it doesn't exist
if not PlayerStats then
    PlayerStats = _G.PlayerStats or {}
    _G.PlayerStats = PlayerStats
end

-- Create Utils module
PlayerStats.Utils = PlayerStats.Utils or {}
local Utils = PlayerStats.Utils

-- Cache frequently used functions
local format = string.format
local floor = math.floor
local max = math.max

-- Utility command handler
function Utils:HandleCommand(msg)
    if msg == "testkill" then
        -- Use Statistics module for recording test kill
        if PlayerStats.Statistics then
            PlayerStats.Statistics:RecordKill(false)
        else
            -- Fallback to direct update
            PlayerStatsDB.kills = (PlayerStatsDB.kills or 0) + 1
            PlayerStats.Sessions:UpdateSessionKill(false)
            PlayerStats:UpdateDisplay()
        end
        print("PlayerStats+ Manual kill added. Total kills:", PlayerStatsDB.kills)
    elseif msg == "testpvp" then
        -- Use Statistics module for recording test PVP kill
        if PlayerStats.Statistics then
            PlayerStats.Statistics:RecordKill(true)
        else
            -- Fallback to direct update
            PlayerStatsDB.pvpKills = (PlayerStatsDB.pvpKills or 0) + 1
            PlayerStats.Sessions:UpdateSessionKill(true)
            PlayerStats:UpdateDisplay()
        end
        print("PlayerStats+ Manual PVP kill added. Total PVP kills:", PlayerStatsDB.pvpKills)
    elseif msg == "stats" then
        Utils:ShowStats()
    elseif msg == "check" then
        Utils:ShowPositionInfo()
    elseif msg == "reset" then
        Utils:ResetToDefaults()
    else
        Utils:ShowHelp()
    end
end



-- Show current statistics
function Utils:ShowStats()
    print("PlayerStats+ Current Stats:")
    print("  Kills:", PlayerStatsDB.kills or 0)
    print("  Deaths:", PlayerStatsDB.deaths or 0)
    print("  PVP Kills:", PlayerStatsDB.pvpKills or 0)
    print("  PVP Deaths:", PlayerStatsDB.pvpDeaths or 0)
    print("  Session Active:", PlayerStatsDB.sessionActive or false)
    
    if PlayerStatsDB.sessionActive then
        print("  Session Kills:", PlayerStatsDB.sessionKills or 0)
        print("  Session PVP Kills:", PlayerStatsDB.sessionPvpKills or 0)
    end
end

-- Show position information
function Utils:ShowPositionInfo()
    print("Current saved position:")
    print("  point:", PlayerStatsDB.point)
    print("  relativePoint:", PlayerStatsDB.relativePoint)
    print("  posX:", PlayerStatsDB.posX)
    print("  posY:", PlayerStatsDB.posY)
    print("  locked:", PlayerStatsDB.locked)
    print("  lastSaved:", PlayerStatsDB.lastSaved)
    print("  version:", PlayerStatsDB._version)
    
    if PlayerStats.MainFrame then
        local point, _, relativePoint, x, y = PlayerStats.MainFrame:GetPoint()
        print("Current frame position:")
        print("  point:", point)
        print("  relativePoint:", relativePoint)
        print("  posX:", x)
        print("  posY:", y)
    else
        print("MainFrame does not exist")
    end
end

-- Reset to defaults
function Utils:ResetToDefaults()
    PlayerStatsDB = {}
    for k, v in pairs(PlayerStats.defaults) do
        PlayerStatsDB[k] = v
    end
    print("Saved variables reset to defaults")
end

-- Show help
function Utils:ShowHelp()
    print("PlayerStats+ Utility Commands:")
    print("  /psutil testkill - Add a test kill")
    print("  /psutil testpvp - Add a test PVP kill")
    print("  /psutil stats - Show current stats")
    print("  /psutil check - Show position info")
    print("  /psutil reset - Reset all data")
    print("")
    print("Note: Frame size and font settings are now available in the config interface (/ps config)")
end
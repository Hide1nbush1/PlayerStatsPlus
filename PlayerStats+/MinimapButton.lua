-- MinimapButton.lua - Minimap Button Module for PlayerStats+
local addonName, PlayerStats = ...

-- Get required libraries
local LibStub = LibStub
local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

-- Create PlayerStats table if it doesn't exist
if not PlayerStats then
    PlayerStats = _G.PlayerStats or {}
    _G.PlayerStats = PlayerStats
end

-- Create MinimapButton module
PlayerStats.MinimapButton = PlayerStats.MinimapButton or {}
local MinimapButton = PlayerStats.MinimapButton

-- Data Broker object for the minimap button
local dataObj = LDB:NewDataObject("PlayerStats+", {
    type = "data source",
    text = "PlayerStats+",
    icon = "Interface\\AddOns\\" .. addonName .. "\\Minimap.tga",
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Left click: Start/Stop session
            MinimapButton:ToggleSession()
        elseif button == "RightButton" then
            -- Right click: Open/Close config
            MinimapButton:ToggleConfig()
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        
        tooltip:AddLine("PlayerStats+")
        tooltip:AddLine(" ")
        
        -- Show session status
        if PlayerStatsDB and PlayerStatsDB.sessionActive then
            tooltip:AddLine("|cff00ff00Session: ACTIVE|r")
            if PlayerStats.Sessions then
                local status = PlayerStats.Sessions:GetSessionStatus()
                if status and status.active then
                    tooltip:AddLine("Duration: " .. (status.duration or "00:00:00"))
                    tooltip:AddLine(string.format("Kills: %d | Deaths: %d", 
                        status.kills or 0, status.deaths or 0))
                    tooltip:AddLine(string.format("PVP K: %d | PVP D: %d", 
                        status.pvpKills or 0, status.pvpDeaths or 0))
                    tooltip:AddLine(string.format("XP Gained: %d", status.xpGained or 0))
                end
            end
        else
            tooltip:AddLine("|cffff0000Session: INACTIVE|r")
        end
        
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffFFFF00Left Click:|r Start/Stop Session")
        tooltip:AddLine("|cffFFFF00Right Click:|r Toggle Configuration")
    end,
})

-- Cleanup function for addon unload/reload
function MinimapButton:Cleanup()
    if icon and icon:IsRegistered("PlayerStats+") then


    end
end

-- Initialize the minimap button
function MinimapButton:Initialize()
    -- Ensure PlayerStatsDB exists
    if not PlayerStatsDB then
        PlayerStatsDB = {}
    end
    
    -- Initialize minimap button settings
    if not PlayerStatsDB.minimap then
        PlayerStatsDB.minimap = {
            hide = false,
        }
    end
    
    -- Check if already registered and handle appropriately
    if icon:IsRegistered("PlayerStats+") then
        -- Already registered, just refresh the existing one
        icon:Refresh("PlayerStats+", PlayerStatsDB.minimap)
    else
        -- Register the icon with LibDBIcon for the first time
        icon:Register("PlayerStats+", dataObj, PlayerStatsDB.minimap)
    end
    
    -- Show/hide based on saved setting
    if PlayerStatsDB.minimap.hide then
        icon:Hide("PlayerStats+")
    else
        icon:Show("PlayerStats+")
    end
end

-- Toggle session (left click functionality)
function MinimapButton:ToggleSession()
    if not PlayerStats.Sessions then
        return
    end
    
    if PlayerStatsDB.sessionActive then
        PlayerStats.Sessions:StopSession()

    else
        PlayerStats.Sessions:StartSession()

    end
    
    -- Update tooltip data
    MinimapButton:UpdateTooltip()
end

-- Toggle config frame (right click functionality)
function MinimapButton:ToggleConfig()
    -- Check if the config frame is already open
    local configFrameOpen = false
    
    -- Check if PlayerStatsFrame exists and is shown
    if _G["PlayerStatsFrame"] and _G["PlayerStatsFrame"]:IsShown() then
        configFrameOpen = true
    end
    
    if configFrameOpen then
        -- Close the config frame
        if _G["PlayerStatsFrame"] then
            _G["PlayerStatsFrame"]:Hide()
        end
    else
        -- Open the config frame
        if _G.SlashCmdList and _G.SlashCmdList["PLAYERSTATS"] then
            _G.SlashCmdList["PLAYERSTATS"]("config")
        end
    end
end

-- Update tooltip information
function MinimapButton:UpdateTooltip()
    -- Force tooltip refresh by updating the data object
    if dataObj then
        dataObj.text = PlayerStatsDB.sessionActive and "Session Active" or "Session Inactive"
    end
end

-- Show/Hide minimap button
function MinimapButton:Show()
    if PlayerStatsDB then
        PlayerStatsDB.minimap.hide = false
        icon:Show("PlayerStats+")
    end
end

function MinimapButton:Hide()
    if PlayerStatsDB then
        PlayerStatsDB.minimap.hide = true
        icon:Hide("PlayerStats+")
        print("|cff00ff00PlayerStats+|r: Minimap button hidden. Reload UI to apply changes.")
    end
end

function MinimapButton:IsShown()
    return PlayerStatsDB and not PlayerStatsDB.minimap.hide
end

-- Toggle visibility
function MinimapButton:ToggleVisibility()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Get position for manual positioning (if needed)
function MinimapButton:GetPosition()
    if PlayerStatsDB and PlayerStatsDB.minimap then
        return PlayerStatsDB.minimap.minimapPos or 225
    end
    return 225
end

-- Set position manually (if needed)
function MinimapButton:SetPosition(angle)
    if PlayerStatsDB and PlayerStatsDB.minimap then
        PlayerStatsDB.minimap.minimapPos = angle
        if PlayerStats.SaveAllSettings then
            PlayerStats:SaveAllSettings()
        end
    end
end



-- Prevent multiple initializations
local isInitialized = false

-- Initialize when addon loads
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
    if event == "ADDON_LOADED" and loadedAddonName == addonName then
        -- Mark that our addon is loaded but don't initialize yet
        self.addonLoaded = true
    elseif event == "PLAYER_LOGIN" and self.addonLoaded and not isInitialized then
        -- Initialize only after player login and our addon is loaded
        isInitialized = true
        -- Small delay to ensure all modules are ready
        local timer = CreateFrame("Frame")
        local elapsed = 0
        timer:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= 1.0 then -- Longer delay to ensure stability
                MinimapButton:Initialize()
                self:SetScript("OnUpdate", nil)
            end
        end)
        self:UnregisterAllEvents()
    end
end)



-- Add slash command for minimap button control
SLASH_PLAYERSTATS_MINIMAP1 = "/psminimap"
SlashCmdList["PLAYERSTATS_MINIMAP"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "show" then
        MinimapButton:Show()
    elseif command == "hide" then
        MinimapButton:Hide()
    elseif command == "toggle" then
        MinimapButton:ToggleVisibility()
    elseif command == "reset" then
        if PlayerStatsDB and PlayerStatsDB.minimap then
            PlayerStatsDB.minimap.minimapPos = 225
            icon:Refresh("PlayerStats+")

        end
    else
        print("PlayerStats+ Minimap Commands:")
        print("  /psminimap show - Show minimap button")
        print("  /psminimap hide - Hide minimap button")
        print("  /psminimap toggle - Toggle minimap button visibility")
        print("  /psminimap reset - Reset minimap button position")
    end
end
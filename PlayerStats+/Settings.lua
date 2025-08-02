local AceGUI = LibStub("AceGUI-3.0")
-- Get the existing PlayerStats+ addon object
local addonName, PlayerStats = ...

local frameShown = false
local frame -- declare frame variable
local lockCheckbox -- store reference to lock checkbox for updates

-- Function to update the lock checkbox state
local function UpdateLockCheckbox()
    if lockCheckbox and PlayerStatsDB then
        lockCheckbox:SetValue(PlayerStatsDB.locked)
    end
end

-- function that draws the widgets for the config tab
local function DrawConfig(container)
    local desc = AceGUI:Create("Label")
    desc:SetText("Frame Settings")
    desc:SetFullWidth(true)
    container:AddChild(desc)

    -- Top row: Lock checkbox and Font Size dropdown side by side
    local topRow = AceGUI:Create("SimpleGroup")
    topRow:SetLayout("Flow")
    topRow:SetFullWidth(true)
    container:AddChild(topRow)

    -- Lock/Unlock checkbox (left side)
    lockCheckbox = AceGUI:Create("CheckBox")
    lockCheckbox:SetLabel("Lock Info Frame")
    local currentLockState = PlayerStatsDB and PlayerStatsDB.locked or false
    lockCheckbox:SetValue(currentLockState)
    lockCheckbox:SetWidth(200)
    lockCheckbox:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.locked = value
            if PlayerStats and PlayerStats.SetLocked then
                PlayerStats:SetLocked(value)
            end
        end
    end)
    topRow:AddChild(lockCheckbox)

    -- Font Size Dropdown (right side)
    local fontSizeDropdown = AceGUI:Create("Dropdown")
    fontSizeDropdown:SetLabel("Text Font Size")
    fontSizeDropdown:SetList({
        ["small"] = "Small Text",
        ["normal"] = "Normal Text", 
        ["big"] = "Big Text"
    })
    local currentFontSize = PlayerStatsDB and PlayerStatsDB.frameSize or "normal"
    fontSizeDropdown:SetValue(currentFontSize)
    fontSizeDropdown:SetWidth(200)
    fontSizeDropdown:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.frameSize = value  -- Keep same variable for compatibility
            if PlayerStats and PlayerStats.ApplyFontSize then
                PlayerStats:ApplyFontSize(value)
            end
            if PlayerStats and PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    topRow:AddChild(fontSizeDropdown)

    -- Add spacing
    local spacing1 = AceGUI:Create("Label")
    spacing1:SetText("")
    spacing1:SetFullWidth(true)
    container:AddChild(spacing1)

    -- Checkboxes arranged in 2 rows (4 in first row, 3 in second row)
    local checkboxGroup = AceGUI:Create("SimpleGroup")
    checkboxGroup:SetLayout("Flow")
    checkboxGroup:SetFullWidth(true)
    container:AddChild(checkboxGroup)

    -- Row 1: First 4 checkboxes
    local row1 = AceGUI:Create("SimpleGroup")
    row1:SetLayout("Flow")
    row1:SetFullWidth(true)
    checkboxGroup:AddChild(row1)

    -- Show Kills checkbox
    local killsCheck = AceGUI:Create("CheckBox")
    killsCheck:SetLabel("Show Kills")
    killsCheck:SetValue(PlayerStatsDB and PlayerStatsDB.showKills ~= false) -- Default to true if not explicitly false
    killsCheck:SetWidth(150)
    killsCheck:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.showKills = value
            if PlayerStats and PlayerStats.UpdateDisplay then
                PlayerStats:UpdateDisplay()
            end
            if PlayerStats and PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    row1:AddChild(killsCheck)

    -- Show Deaths checkbox
    local deathsCheck = AceGUI:Create("CheckBox")
    deathsCheck:SetLabel("Show Deaths")
    deathsCheck:SetValue(PlayerStatsDB and PlayerStatsDB.showDeaths ~= false) -- Default to true if not explicitly false
    deathsCheck:SetWidth(150)
    deathsCheck:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.showDeaths = value
            if PlayerStats and PlayerStats.UpdateDisplay then
                PlayerStats:UpdateDisplay()
            end
            if PlayerStats and PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    row1:AddChild(deathsCheck)

    -- Show K/D Ratio checkbox
    local kdRatioCheck = AceGUI:Create("CheckBox")
    kdRatioCheck:SetLabel("Show PVP K/D Ratio")
    kdRatioCheck:SetValue(PlayerStatsDB and PlayerStatsDB.showKDRatio ~= false) -- Default to true if not explicitly false
    kdRatioCheck:SetWidth(150)
    kdRatioCheck:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.showKDRatio = value
            if PlayerStats and PlayerStats.UpdateDisplay then
                PlayerStats:UpdateDisplay()
            end
            if PlayerStats and PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    row1:AddChild(kdRatioCheck)

    -- Show PVP Stats checkbox
    local pvpCheck = AceGUI:Create("CheckBox")
    pvpCheck:SetLabel("Show PVP Stats")
    pvpCheck:SetValue(PlayerStatsDB and PlayerStatsDB.showPVP ~= false) -- Default to true if not explicitly false
    pvpCheck:SetWidth(150)
    pvpCheck:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.showPVP = value
            if PlayerStats and PlayerStats.UpdateDisplay then
                PlayerStats:UpdateDisplay()
            end
            if PlayerStats and PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    row1:AddChild(pvpCheck)

    -- Row 2: Next 3 checkboxes
    local row2 = AceGUI:Create("SimpleGroup")
    row2:SetLayout("Flow")
    row2:SetFullWidth(true)
    checkboxGroup:AddChild(row2)

    -- XP tracking checkbox
    local xpCheck = AceGUI:Create("CheckBox")
    xpCheck:SetLabel("XP Tracking")
    xpCheck:SetDescription("Show current XP and XP per hour")
    xpCheck:SetValue(PlayerStatsDB and PlayerStatsDB.showXP ~= false) -- Default to true if not explicitly false
    xpCheck:SetWidth(150)
    xpCheck:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStatsDB then
            PlayerStatsDB.showXP = value
            if PlayerStats and PlayerStats.UpdateDisplay then
                PlayerStats:UpdateDisplay()
            end
            if PlayerStats and PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    row2:AddChild(xpCheck)

    -- Minimap Button checkbox
    local minimapCheck = AceGUI:Create("CheckBox")
    minimapCheck:SetLabel("Show Minimap Button")
    minimapCheck:SetDescription("Show/hide the minimap button")
    local minimapShown = PlayerStatsDB and PlayerStatsDB.minimap and not PlayerStatsDB.minimap.hide
    minimapCheck:SetValue(minimapShown)
    minimapCheck:SetWidth(150)
    minimapCheck:SetCallback("OnValueChanged", function(widget, event, value)
        if PlayerStats and PlayerStats.MinimapButton then
            if value then
                PlayerStats.MinimapButton:Show()
            else
                PlayerStats.MinimapButton:Hide()
            end
            if PlayerStats.SaveAllSettings then
                PlayerStats:SaveAllSettings()
            end
        end
    end)
    row2:AddChild(minimapCheck)




end

-- Global timer to prevent duplicates
local sessionUpdateTimer = nil

-- Function to cleanup session timer
local function CleanupSessionTimer()
    if sessionUpdateTimer then
        sessionUpdateTimer:SetScript("OnUpdate", nil)
        sessionUpdateTimer = nil
    end
end

-- function that draws the widgets for the sessions tab
local function DrawSessions(container)
    local desc = AceGUI:Create("Label")
    desc:SetText("Session Management")
    desc:SetFullWidth(true)
    container:AddChild(desc)

    -- Session status display
    local statusLabel = AceGUI:Create("Label")
    statusLabel:SetText("Session Status: Not Active")
    statusLabel:SetFullWidth(true)
    container:AddChild(statusLabel)

    -- Session info display
    local infoLabel = AceGUI:Create("Label")
    infoLabel:SetText("")
    infoLabel:SetFullWidth(true)
    container:AddChild(infoLabel)

    -- Add spacing between info and button
    local spacingLabel = AceGUI:Create("Label")
    spacingLabel:SetText("")
    spacingLabel:SetFullWidth(true)
    container:AddChild(spacingLabel)

    -- Function to update session display
    local function UpdateSessionDisplay()
        if PlayerStats and PlayerStats.Sessions then
            local status = PlayerStats.Sessions:GetSessionStatus() or { active = false }
            if status.active then
                statusLabel:SetText("Session Status: ACTIVE")
                infoLabel:SetText(string.format("Duration: %s | Kills: %d | Deaths: %d | PVP Kills: %d | PVP Deaths: %d | XP: %d", 
                    status.duration, status.kills, status.deaths, status.pvpKills, status.pvpDeaths, status.xpGained))
            else
                statusLabel:SetText("Session Status: Not Active")
                infoLabel:SetText("")
            end
        end
    end

    -- Sessions list
    local sessionsList = AceGUI:Create("MultiLineEditBox")
    sessionsList:SetLabel("Session History")
    sessionsList:SetNumLines(10)
    sessionsList:SetFullWidth(true)
    sessionsList:DisableButton(true)
    
    -- Function to update sessions list
    local function UpdateSessionsList()
        if PlayerStats and PlayerStats.Sessions then
            local sessions = PlayerStats.Sessions:GetSavedSessions() or {}
            if #sessions > 0 then
                local text = ""
                for i = #sessions, 1, -1 do -- Show newest first
                    local session = sessions[i]
                    local startDate = date("%Y-%m-%d %H:%M", session.startTime)
                    local duration = string.format("%02d:%02d:%02d", 
                        math.floor(session.duration / 3600),
                        math.floor((session.duration % 3600) / 60),
                        session.duration % 60)
                    
                    text = text .. string.format("Session %d (%s)\n", i, startDate)
                    text = text .. string.format("  Duration: %s\n", duration)
                    text = text .. string.format("  Kills: %d | Deaths: %d | K/D: %.2f\n", 
                        session.kills, session.deaths, session.kdRatio)
                    text = text .. string.format("  PVP Kills: %d | PVP Deaths: %d | PVP K/D: %.2f\n", 
                        session.pvpKills, session.pvpDeaths, session.pvpKdRatio)
                    text = text .. string.format("  XP Gained: %d\n", session.xpGained)
                    text = text .. "\n"
                end
                sessionsList:SetText(text)
            else
                sessionsList:SetText("No saved sessions")
            end
        end
    end

    -- Stop any existing timer before creating a new one
    CleanupSessionTimer()
    
    -- Create a timer frame for real-time updates
    sessionUpdateTimer = CreateFrame("Frame")
    sessionUpdateTimer:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.5 then -- Update every 0.5 seconds
            self.elapsed = 0
            UpdateSessionDisplay()
        end
    end)

    -- Start/Stop Session button
    local sessionButton = AceGUI:Create("Button")
    sessionButton:SetText("Start Session")
    sessionButton:SetWidth(150)
    sessionButton:SetCallback("OnClick", function()
        if PlayerStats then
            if PlayerStatsDB.sessionActive then
                PlayerStats.Sessions:StopSession()
                sessionButton:SetText("Start Session")
                -- Update session history immediately after stopping session
                UpdateSessionsList()
            else
                PlayerStats.Sessions:StartSession()
                sessionButton:SetText("Stop Session")
            end
            UpdateSessionDisplay()
        end
    end)
    container:AddChild(sessionButton)

    -- Update button text based on current state
    if PlayerStatsDB and PlayerStatsDB.sessionActive then
        sessionButton:SetText("Stop Session")
    end

    -- Update display initially
    UpdateSessionDisplay()

    -- Separator
    local separator = AceGUI:Create("Label")
    separator:SetText("")
    separator:SetFullWidth(true)
    container:AddChild(separator)

    -- Saved Sessions section
    local savedDesc = AceGUI:Create("Label")
    savedDesc:SetText("Saved Sessions")
    savedDesc:SetFullWidth(true)
    container:AddChild(savedDesc)
    
    container:AddChild(sessionsList)
    UpdateSessionsList()

    -- Clear Sessions button
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear All Sessions")
    clearButton:SetWidth(150)
    clearButton:SetCallback("OnClick", function()
        if PlayerStats then
            PlayerStats.Sessions:ClearSavedSessions()
            UpdateSessionsList()
        end
    end)
    container:AddChild(clearButton)

    -- Refresh button
    local refreshButton = AceGUI:Create("Button")
    refreshButton:SetText("Refresh Display")
    refreshButton:SetWidth(150)
    refreshButton:SetCallback("OnClick", function()
        UpdateSessionDisplay()
        UpdateSessionsList()
    end)
    container:AddChild(refreshButton)
end

local function ShowPlayerStatsConfig()
    if frameShown then 
        -- If config is already open, just bring it to front
        frame.frame:Show()
        frame.frame:Raise()
        return 
    end

    frame = AceGUI:Create("Frame")
    -- Set the global name for the underlying Blizzard frame
    frame.frame:SetAttribute("UIPanelLayout-area", "center")
    frame.frame:SetAttribute("UIPanelLayout-enabled", true)
    frame.frame.name = "PlayerStatsFrame"
    _G["PlayerStatsFrame"] = frame.frame
    tinsert(UISpecialFrames, "PlayerStatsFrame")

    frame:SetCallback("OnClose", function(widget)
        -- Clean up the session timer when closing the frame
        CleanupSessionTimer()
        AceGUI:Release(widget)
        frameShown = false
        frame = nil
    end)
    frame:SetTitle("PlayerStats+")
    frame:SetStatusText("Powered by Ace 3")
    frame:SetLayout("Fill")
    
    -- Set resize limits on the underlying Blizzard frame to prevent clipping widgets
    if frame.frame then
        frame.frame:SetMinResize(500, 400)  -- Minimum width: 350, height: 400
        frame.frame:SetMaxResize(600, 500)  -- Maximum width: 600, height: 800
    end
    
    frameShown = true

    local tab = AceGUI:Create("TabGroup")
    tab:SetLayout("Flow")
    tab:SetTabs({
      {text="Config", value="config"},
      {text="Sessions", value="sessions"},
    })
    tab:SetCallback("OnGroupSelected", function(container, event, group)
        -- Clean up the session timer when switching tabs
        CleanupSessionTimer()
        container:ReleaseChildren()
        if group == "config" then
           DrawConfig(container)
        elseif group == "sessions" then
           DrawSessions(container)
        end
    end)
    tab:SelectTab("config")
    frame:AddChild(tab)
end

SlashCmdList["RELOAD_RELOADUI"] = function()
    Reload_ReloadUI();
end
SLASH_RELOAD_RELOADUI1 = "/reload";
SLASH_RELOAD_RELOADUI2 = "/reloadui";
SLASH_RELOAD_RELOADUI3 = "/rl";
function Reload_ReloadUI()
   ReloadUI();
end

-- Slash command handler
SLASH_PLAYERSTATS1 = "/ps"
SLASH_PLAYERSTATS2 = "/playerstats"
SlashCmdList["PLAYERSTATS"] = function(msg)
    local command = string.lower(msg or "")
    
    if command == "lock" then
        if PlayerStats and PlayerStats.SetLocked then
            PlayerStats:SetLocked(true)
            UpdateLockCheckbox()

        end
    elseif command == "unlock" then
        if PlayerStats and PlayerStats.SetLocked then
            PlayerStats:SetLocked(false)
            UpdateLockCheckbox()

        end
    elseif command == "toggle" then
        if PlayerStats and PlayerStats.SetLocked then
            local newState = not PlayerStatsDB.locked
            PlayerStats:SetLocked(newState)
            UpdateLockCheckbox()

        end
    elseif command == "" or command == "config" then
        -- Open config window
        ShowPlayerStatsConfig()
    else
        print("PlayerStats+ Commands:")
        print("  /ps or /playerstats - Open configuration")
        print("  /pss - Open sessions tab directly")
        print("  /ps lock - Lock the frame")
        print("  /ps unlock - Unlock the frame")
        print("  /ps toggle - Toggle lock state")
    end
end

-- Sessions tab command
SLASH_PLAYERSTATS_SESSIONS1 = "/pss"
SlashCmdList["PLAYERSTATS_SESSIONS"] = function(msg)
    -- Open config window and switch to sessions tab
    ShowPlayerStatsConfig()
            -- Switch to sessions tab immediately if frame exists
        if frame and frame.children and frame.children[1] and frame.children[1].SelectTab then
            frame.children[1]:SelectTab("sessions")
        end
end

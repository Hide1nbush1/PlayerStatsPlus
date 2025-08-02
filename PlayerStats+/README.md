# PlayerStats+ Addon

A comprehensive World of Warcraft 3.3.5a (WotLK) addon for tracking player statistics, sessions, and performance metrics.


<img width="162" height="186" alt="image" src="https://github.com/user-attachments/assets/9360dad9-978c-4fbd-8fe3-77218a5dc1ea" />


<img width="834" height="619" alt="image" src="https://github.com/user-attachments/assets/eb9cd670-f949-457b-a8b0-b5670a5d64c4" />



<img width="879" height="656" alt="image" src="https://github.com/user-attachments/assets/39ff2efb-13b6-4a5e-9034-34afc4403175" />



## Features

### 📊 Statistics Tracking
- **Kills & Deaths**: Track total kills and deaths
- **PVP Statistics**: Separate tracking for PVP kills and deaths
- **K/D Ratio**: Automatic calculation of PVP kill/death ratio
- **Experience Tracking**: Current XP, total XP, and XP per hour calculation
- **Class Colors**: Player name displayed in class-appropriate colors
- **Level Display**: Current level shown next to player name

### ⏱️ Session Management
- **Session Tracking**: Start/stop sessions to track performance during specific time periods
- **Session Statistics**: Separate counters for kills, deaths, PVP kills, PVP deaths, and XP gained during sessions
- **Session History**: Save and view previous session data
- **Session Progress**: Real-time display of current session statistics

### 🎮 User Interface
- **Movable Frame**: Drag and drop the stats frame anywhere on screen
- **Lockable Frame**: Prevent accidental movement with lock feature
- **Static Frame**: No manual resizing - frame automatically adjusts to content
- **Font Size Control**: Three predefined text sizes (Small, Normal, Big) via dropdown
- **Auto-Resize**: Frame automatically adjusts dimensions based on visible content and font size
- **Backdrop**: Semi-transparent backdrop appears during frame movement for better visibility
- **Screen Clamping**: Frame stays within screen boundaries

### ⚙️ Configuration
- **In-Game Config**: Full configuration interface using AceGUI-3.0
- **Modular Settings**: Toggle individual statistics on/off
- **Persistent Settings**: All settings saved between sessions
- **Minimap Button**: Optional minimap button for quick access (using LibDBIcon-1.0)

### 🔧 Utility Commands
- **`/ps`**: Main addon command
- **`/pss`**: Session management commands
- **`/psutil`**: Utility commands for debugging and management
- **`/psminimap`**: Minimap button control commands

## Installation

1. Download the addon files
2. Extract to `World of Warcraft/Interface/AddOns/PlayerStats+`
3. Restart WoW or reload UI (`/reload`)

### Basic Commands
```
/ps                    - Show help
/pss start            - Start a new session
/pss stop             - Stop current session
/pss status           - Show session status
/psutil help          - Show utility commands
/psminimap show       - Show minimap button
/psminimap hide       - Hide minimap button
/psminimap toggle     - Toggle minimap button visibility
/psminimap reset      - Reset minimap button position
```

### Configuration
1. Right-click the minimap button or use `/ps` to open config
2. Use the dropdown to change text font size
3. Toggle individual statistics on/off
4. Lock/unlock the frame position
5. Show/hide minimap button

### Session Management
- **Left-click minimap button**: Start/stop session
- **Right-click minimap button**: Open configuration
- Sessions track kills, deaths, PVP activity, and XP gained
- Session data is saved and can be viewed in the config

### Minimap Button Features
- **Interactive Tooltip**: Shows current session status and statistics
- **Session Control**: Left-click to start/stop sessions
- **Quick Config**: Right-click to open configuration
- **Position Control**: Drag to reposition on minimap
- **Visibility Toggle**: Show/hide through settings or commands
- **Reload Notification**: Informative message when button is hidden

## Technical Details

### Architecture
- **Modular Design**: Code split into separate modules (Core, Sessions, Statistics, Utils, Settings, MinimapButton)
- **Event-Driven**: Uses WoW's event system for real-time updates
- **Performance Optimized**: Throttled updates to prevent performance issues
- **Memory Efficient**: Minimal memory footprint with efficient data structures

### Data Persistence
- **SavedVariables**: All settings and statistics saved to `PlayerStatsDB`
- **Character-Specific**: Data saved per character
- **Automatic Saving**: Settings saved automatically when changed

### Combat Log Integration
- **PARTY_KILL Events**: Reliable kill tracking using WoW 3.3.5a combat log
- **Player Detection**: Multiple methods to distinguish player kills from NPC kills
- **PVP Detection**: Automatic detection of PVP encounters

### UI Framework
- **AceGUI-3.0**: Modern, consistent UI components
- **LibDBIcon-1.0**: Professional minimap button integration
- **Dynamic Sizing**: Frame automatically adjusts to content
- **Responsive Design**: Adapts to different screen resolutions
- **Accessibility**: Clear visual feedback and tooltips

## File Structure

```
PlayerStats+/
├── PlayerStats+.toc          # Addon metadata and file loading
├── Core.lua                  # Main addon logic and frame creation
├── Sessions.lua              # Session management module
├── Statistics.lua            # Statistics tracking module
├── Utils.lua                 # Utility commands module
├── Settings.lua              # Configuration UI
├── MinimapButton.lua         # Minimap button functionality
├── Minimap.TGA               # Minimap button icon
├── embeds.xml                # Ace3 library embedding
└── libs/                     # Embedded libraries
    ├── Ace3/                 # Ace3 framework
    └── LibDBIcon-1.0/        # Minimap button library
```

## Recent Changes

### Version 1.0 (Latest)
- **Minimap Button Improvements**: Enhanced minimap button with better tooltip and session integration
- **Reload Notification**: Simple chat message when minimap button is hidden
- **Better Error Handling**: Improved compatibility with WoW 3.3.5a
- **Cleaner Code**: Removed complex notification frames in favor of simple chat messages
- **Enhanced Tooltips**: More detailed session information in minimap button tooltip

### Version 1.0 (Previous)
- **Complete Rewrite**: Modular architecture with separate files for different functionality
- **LibDBIcon Integration**: Professional minimap button using LibDBIcon-1.0
- **Static Frame**: Removed manual resizing in favor of automatic content-based sizing
- **Font Size Control**: Dropdown-based font size selection instead of manual resizing
- **Enhanced Session Tracking**: Improved session management with better data persistence
- **Performance Improvements**: Optimized update throttling and memory usage
- **Better Error Handling**: Robust error checking and fallback mechanisms
- **Cleaner UI**: Simplified interface with better visual feedback

### Key Improvements
- **Stability**: Eliminated crashes related to frame resizing and notification systems
- **Usability**: Simplified controls and better user experience
- **Maintainability**: Modular code structure for easier maintenance
- **Compatibility**: Better compatibility with WoW 3.3.5a
- **Reliability**: More robust data saving and loading
- **User Feedback**: Clear notifications and tooltips for better user experience

## Troubleshooting

### Common Issues
1. **Addon not loading**: Check that Ace3 libraries are installed
2. **Minimap button not showing**: Ensure LibDBIcon-1.0 is available
3. **Settings not saving**: Try `/reload` to force save
4. **Session not tracking**: Check if session is active with `/pss status`
5. **Minimap button hidden**: Use `/psminimap show` to restore it

### Utility Commands
- `/psutil help`: View all available utility commands
- `/psminimap help`: View minimap button control commands

## Contributing

This addon is designed for WoW 3.3.5a (WotLK). When making changes:
- Test thoroughly in the target WoW version
- Maintain backward compatibility with existing saved data
- Follow the modular architecture pattern
- Update this README for any new features
- Use Ace3 libraries for UI components
- Keep the code simple and maintainable

## License

This addon is provided as-is for personal use. Feel free to modify and distribute according to your needs.

---

**Author**: Hide1nbush1  
**Version**: 1.0  
**WoW Version**: 3.3.5a (WotLK) 

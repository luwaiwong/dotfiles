# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Quickshell configuration for Hyprland on Wayland. Quickshell is a QtQuick-based shell framework that provides customizable panels, bars, and widgets for Linux desktop environments.

## Running the Shell

```bash
# Launch quickshell with correct environment
./launchshell.sh
# Or manually:
QT_SCALE_FACTOR=1 QT_QPA_PLATFORM=wayland quickshell

# Reload the shell (from within quickshell)
# The shell auto-detects changes and shows a ReloadPopup on success/failure
```

## Requirements

- qt5-graphicaleffects
- brightnessctl (for brightness control)
- Hyprland window manager

## Architecture

### Entry Point
- `shell.qml` - Main entry point using `ShellRoot`, loads all modules

### Global Singleton
- `Style.qml` - Global styling singleton (border width, radius, font families)

### Modules (`modules/`)
Each module is a self-contained UI component:
- **topBar/** - Dynamic auto-hiding top bar with clock, workspaces, media, system tray
- **bottomBar/** - Bottom status bar with battery display
- **leftDrawer/** - Left slide-out drawer with wallpaper picker
- **rightDrawer/** - Right slide-out drawer with audio/brightness controls
- **border/** - Screen border decorations (top, bottom, left, right edges)

### Module Structure Pattern
Most modules follow this pattern:
- `*State.qml` - State management with show/hide logic, timers, hover handlers
- `Background.qml` - Visual background/shape of the component
- `Content.qml` - Actual content/widgets layout
- `widgets/` subdirectory - Individual widget components

### Utilities (`utils/`)
Singleton services providing system data:
- `HyprlandData.qml` - Extended Hyprland data (window list, monitors) via `hyprctl`
- `Brightness.qml` - Screen brightness control via `brightnessctl`
- `MprisController.qml` - Media player control (tracks active player, play/pause/next/previous)
- `Bluetooth.qml` - Bluetooth state management
- `Time.qml` - Time/date service
- `AppSearch.qml` - Application search with fuzzy matching

### Components (`components/`)
Reusable UI components:
- `ReloadPopup.qml` - Shows reload success/failure notification
- `StyledSlider.qml` - Custom styled slider widget

## Key Patterns

### State Management
UI visibility controlled by `*State.qml` files with:
- Boolean state properties (`show`, `showTopBar`, `hovering`)
- Timer-based show/hide delays
- Hover event handlers (`onMainTopBarHovered`)
- Hyprland event listeners for auto-hide behavior

### Path Imports
- `"root:/"` - Project root
- `"root:/utils"` - Utils directory
- Relative paths for module-local imports

### Multi-Monitor Support
Uses `Variants { model: Quickshell.screens }` pattern to create instances per screen.

### Wayland Layer Shell
PanelWindows use `WlrLayershell.exclusionMode` and `mask: Region {}` to control input handling and screen space reservation.

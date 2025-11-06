# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This directory contains shell scripts for managing AeroSpace window layouts and workspace configurations. AeroSpace is a tiling window manager for macOS that provides i3-like functionality with native macOS integration.

## Key Scripts

### workspace_layouts.sh
- **Purpose**: Creates automated workspace layouts by opening and arranging specific applications
- **Usage**: `./workspace_layouts.sh [workspace_name]` (defaults to "zoom")
- **Dependencies**: `aerospace` CLI, `jq`, `open` command
- **Functionality**:
  - Opens zoom.us, Obsidian, and Arc applications if not running
  - Moves all windows to the specified workspace
  - Arranges windows in a specific layout with zoom/obsidian on the left, Arc on the right
  - Uses AeroSpace's join-with command to create window groups

## AeroSpace Integration

The scripts work with AeroSpace configuration located at `../../.aerospace.toml`. Key bindings:
- `Alt + H/J/K/L` - Navigate windows
- `Alt + Shift + H/J/K/L` - Move windows  
- `Alt + /` - Toggle horizontal/vertical layout
- `Alt + Shift + ;` - Enter service mode for advanced operations
- `Ctrl + Left/Right` - Navigate workspaces

## Architecture

### Window Management Pattern
Scripts use a consistent pattern:
1. Query existing windows via `aerospace list-windows --all --json`
2. Parse JSON output with `jq` to find specific applications
3. Open applications if not running using `open -a`
4. Wait for windows to appear with polling loop
5. Move windows to target workspace using `aerospace move-node-to-workspace`
6. Arrange windows using movement and join commands

### Error Handling
- Scripts use `set -eu -o pipefail` for strict error handling
- Application launch failures are caught and reported
- Window polling ensures applications are fully loaded before manipulation

## Common Commands

### Testing Scripts
```bash
# Run workspace layout script with default "zoom" workspace
./workspace_layouts.sh

# Run with custom workspace name
./workspace_layouts.sh "meeting"
```

### AeroSpace CLI Usage
```bash
# List all windows with JSON output
aerospace list-windows --all --json

# Move specific window to workspace
aerospace move-node-to-workspace --window-id <id> <workspace>

# Flatten workspace layout
aerospace flatten-workspace-tree --workspace <name>
```

## Development Guidelines

- Always test scripts with different application states (running/not running)
- Use proper error handling for application launches
- Include sleep delays when waiting for applications to fully load
- Follow the existing pattern of JSON parsing with jq for window queries
- Workspace names should be descriptive and consistent with AeroSpace configuration
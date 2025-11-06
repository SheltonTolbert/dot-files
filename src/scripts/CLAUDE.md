# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This directory contains a collection of utility scripts for development workflow automation, window management, and system integration. The scripts are organized into specialized subdirectories with specific purposes, and include shared utilities at the root level.

## Architecture

### Directory Structure
- **aerospace/**: AeroSpace window manager scripts for macOS workspace automation
- **dfm/**: "Do it for me" script dispatcher system with AI-powered development workflows  
- **dscout/**: Work-specific automation scripts for dscout development workflows
- **snippets/**: Code snippet management system with fuzzy finder interface

### Common Patterns

#### Script Execution Standards
- All scripts use `#!/bin/bash` shebang
- Error handling with `set -eu -o pipefail` (where applicable)
- Support for `--force` flag to bypass caching
- Consistent help/usage information

#### Caching System
Scripts use a standardized caching pattern:
- Cache location: `$HOME/.tmp/` or `$HOME/.tmp/cache/`
- Commit-based cache file naming for git-related operations
- Cache invalidation via `--force` flag
- Automatic cache directory creation

#### Tool Integration
- **fzf**: Fuzzy finder for interactive selection interfaces
- **jq**: JSON parsing for structured data processing
- **nvim**: Neovim integration for AI-powered workflows (CodeCompanion plugin)
- **git**: Version control operations and commit analysis
- **pbcopy**: macOS clipboard integration

## Core Scripts

### config.sh
Interactive configuration file browser using fzf and Neovim.
```bash
./config.sh [query]  # Opens ~/.config directory with fuzzy search
```

### cache.sh  
General-purpose caching utility for piped content.
```bash
echo "content" | ./cache.sh cache_name    # Write to cache
./cache.sh -r cache_name                  # Read from cache
```

### startup.sh
Development environment initialization script.
- Starts multiple tmuxinator sessions (axon, dendra, servers, config, obsidian)
- Configures AeroSpace workspace layouts

### snippets.sh
Code snippet selection and clipboard copy interface.
```bash
./snippets.sh  # Interactive snippet selection via fzf
```

### karma_focus.sh
Karma test failure analysis and focused test running.
- Parses test failures from Chrome Headless output
- Runs targeted tests using `yarn test:rtl`

### mix_test.sh
Elixir test case analysis for changed files.
- Identifies changed test files via git diff
- Extracts specific test cases and line numbers
- Maps git changes to affected test blocks

### recursive-command.js
Node.js utility for executing commands across directory hierarchies.
```bash
./recursive-command.js [--silent] [path] <command>
```

## Common Commands

### Development Workflow
```bash
# Start development environment
./startup.sh

# Interactive config editing
./config.sh nvim

# Cache content for reuse
echo "some data" | ./cache.sh my_cache
./cache.sh -r my_cache

# Code snippet access
./snippets.sh
```

### Testing and Analysis
```bash
# Focus on failed Karma tests
karma_output | ./karma_focus.sh

# Analyze changed Elixir tests
./mix_test.sh path/to/test_file.exs

# Run command recursively
./recursive-command.js "git status"
```

## Development Guidelines

### Adding New Scripts
- Follow established error handling patterns (`set -eu -o pipefail`)
- Implement caching for expensive operations
- Support common flags (`--force`, `--help`)
- Use fzf for interactive selections
- Include proper usage documentation

### Integration Dependencies
Scripts assume the following tools are available:
- **bash** (primary scripting environment)
- **git** (version control operations)
- **fzf** (fuzzy finding)
- **nvim** with CodeCompanion plugin (AI integration)
- **jq** (JSON processing)
- **node.js** (for .js utilities)

### Script Organization
- Root level: General utilities and system integration
- Subdirectories: Specialized tool sets with dedicated CLAUDE.md files
- Consistent naming conventions without file extensions for executables
- Clear separation between utility functions and main execution logic
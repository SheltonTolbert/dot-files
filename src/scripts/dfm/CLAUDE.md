# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DFM (Do it for me) is a script dispatch system that provides automated development workflows through shell scripts. The system uses a main dispatcher (`dfm.sh`) that dynamically executes script files based on command-line arguments, converting spaces to underscores for script file matching.

## Architecture

### Script Dispatcher Pattern
- **Main Entry Point**: `dfm.sh` serves as the central dispatcher
- **Dynamic Script Loading**: Converts command arguments to script filenames (spaces become underscores)
- **File Execution**: Locates and executes corresponding `.sh` files in the same directory
- **Error Handling**: Validates script existence before execution

### Core Scripts

#### suggest_commit.sh
- **Purpose**: Generates AI-powered commit messages using Neovim's CodeCompanion plugin
- **Functionality**:
  - Gets current branch name and last commit hash
  - Uses temporary file caching in `$HOME/.tmp` directory
  - Integrates with Neovim headless mode for AI generation
  - Supports `--force` flag to regenerate cached results

#### fix_credo.sh
- **Purpose**: Automated code fixing using AI chat interface
- **Integration**: Uses Neovim's CodeCompanion chat mode with `/fix_commit` command
- **Caching**: Similar temporary file pattern as suggest_commit.sh

## Common Commands

### Running Scripts via DFM Dispatcher
```bash
# Execute suggest_commit.sh
./dfm.sh suggest commit

# Execute fix_credo.sh  
./dfm.sh fix credo

# Force regeneration (for cached scripts)
./suggest_commit.sh --force
```

### Direct Script Execution
```bash
# Generate commit message suggestion
./suggest_commit.sh

# Fix code issues with AI assistance
./fix_credo.sh
```

## Integration Dependencies

### Required Tools
- **git**: For branch and commit information
- **nvim**: Neovim with CodeCompanion plugin for AI integration
- **bash**: Shell scripting environment

### Configuration Files
- CodeCompanion hooks: `~/.config/nvim/lua/plugins/code-companion/hooks.lua`
- Temporary directory: `$HOME/.tmp` (auto-created by scripts)

## Development Patterns

### Temporary File Caching
Scripts use a consistent caching pattern:
1. Generate filename from commit hash in `$HOME/.tmp`
2. Check for existing cached results
3. Return cached content unless `--force` flag is used
4. Generate new content via AI integration if needed

### AI Integration Pattern
Scripts follow a standard Neovim headless integration:
1. Load CodeCompanion configuration
2. Execute specific AI commands (`/gen_commit`, `/fix_commit`)
3. Output results to temporary files
4. Display final results to user
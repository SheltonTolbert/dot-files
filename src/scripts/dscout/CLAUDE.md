# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This directory contains work-specific automation scripts for dscout development workflows. dscout is a qualitative research platform, and these scripts are designed to streamline common development tasks and integrate with dscout's internal tooling.

## Architecture

### Integration with Main Repository
- **Aliases Integration**: Work directory is configured via `DSCOUT_DIR="~/repos/dscout"` in main dotfiles
- **Tool Access**: Main dscout development tools (`axon`, `dendra`) are aliased for quick access
- **Jira Integration**: Connected to dscout's Atlassian instance (dscout.atlassian.net) for issue tracking

### Expected Script Categories

Following the established dotfiles pattern, scripts here should handle:
- Development workflow automation (build, test, deploy processes)
- Integration with dscout's internal tools (`axon`, `dendra`)
- Jira ticket management and branch creation workflows
- Environment setup and configuration management

## Common Commands

### Main Repository Access
```bash
# Navigate to dscout repository
dscout

# Access dscout tools
axon [args]
dendra [args]
```

### Development Workflow Pattern
Based on existing dotfiles patterns, scripts should follow:
```bash
# Execute scripts via consistent naming
./[script_name].sh

# Support common flags
./[script_name].sh --force    # Force regeneration/rebuild
./[script_name].sh --help     # Show usage information
```

## Development Guidelines

### Script Patterns
- Use `set -eu -o pipefail` for strict error handling
- Implement caching in `$HOME/.tmp` directory with commit-based naming
- Support `--force` flag for cache invalidation
- Include proper error messages and usage instructions

### Integration Standards
- Scripts should work with existing dscout repository structure
- Leverage existing tool aliases (`axon`, `dendra`) rather than direct paths
- Follow established temporary file caching patterns
- Maintain consistency with other script directories (`dfm/`, `aerospace/`)

### Tool Dependencies
- **git**: For branch and commit operations
- **jira-cli** or **gh**: For issue tracking integration
- **axon/dendra**: dscout-specific development tools
- **bash**: Primary scripting environment

## Expected Scripts

Based on common development workflows and existing patterns:
- Branch/ticket creation scripts integrated with Jira
- Build and deployment automation for dscout projects
- Development environment setup and configuration
- Integration scripts for dscout's CI/CD pipeline
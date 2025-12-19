---
description: Set up a new git worktree using bare repository workflow
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(ln:*), Bash(ls:*), Read(*), sequential-thinking(*)
---

## Context

You are a Git expert helping set up a new worktree in a bare repository workflow. This workflow uses a bare `.git` repository with multiple worktrees for parallel branch development, allowing you to work on multiple branches simultaneously without switching contexts.

## Your Task

Set up a new git worktree following the bare repository pattern. This includes creating the worktree, setting up any shared configurations, and ensuring proper structure.

### Phase 1: Validate Environment

**MANDATORY**: Check the current repository structure:

```bash
# Check if this is a bare repo setup
ls -la | grep -E "\.bare|\.git"

# List existing worktrees
git worktree list

# Check current location
pwd
```

**Decision Points:**
- If `.bare` directory exists: This is a bare repo setup (proceed)
- If only `.git` exists as a directory: This is a standard repo (warn user about conversion needed)
- If `.git` exists as a file: This is already a worktree (navigate to parent)

### Phase 2: Gather Worktree Information

**MANDATORY**: Ask the user or determine:
- Branch name for the new worktree
- Whether to create a new branch or checkout existing branch
- Worktree directory name (defaults to branch name)
- Base branch to branch from (if creating new branch, default: main)

Use the AskUserQuestion tool if information is not provided in $ARGUMENTS.

### Phase 3: Create the Worktree

**MANDATORY**: Create the worktree based on user requirements:

**For new branch:**
```bash
# Create new worktree with new branch
git worktree add -b <branch-name> <worktree-dir> <base-branch>
```

**For existing branch:**
```bash
# Create worktree from existing branch
git worktree add <worktree-dir> <branch-name>
```

**Handle remote branches:**
```bash
# Fetch latest from remote first
git fetch origin

# Create worktree tracking remote branch
git worktree add --track -b <local-branch-name> <worktree-dir> origin/<remote-branch>
```

### Phase 4: Set Up Shared Configurations

**MANDATORY**: Check for shared configuration directories and set up symlinks:

```bash
# Check for shared directories
ls -la | grep -E "\.claude-shared|apps-shared|config-shared"
```

**If shared directories exist:**
- Look for a setup script (e.g., `setup-worktree-symlinks`, `bin/setup-worktree`)
- If script exists, run it for the new worktree: `./bin/setup-worktree-symlinks <worktree-dir>`
- If no script exists, manually create symlinks for common shared files:
  - `.env` files
  - `.claude` configurations
  - Shared application code or configs

**Common symlink patterns:**
```bash
# .claude configurations
mkdir -p <worktree-dir>/.claude
ln -s "$(pwd)/.claude-shared/"* <worktree-dir>/.claude/

# Environment files
ln -s "$(pwd)/.env.shared" <worktree-dir>/.env
```

### Phase 5: Verify Setup

**MANDATORY**: Validate the worktree is properly configured:

```bash
# List all worktrees to confirm creation
git worktree list

# Check the worktree directory structure
ls -la <worktree-dir>

# Verify git status in new worktree
cd <worktree-dir> && git status && cd -

# Check for proper symlinks if applicable
ls -la <worktree-dir>/.claude 2>/dev/null || true
```

### Phase 6: Provide Usage Instructions

**MANDATORY**: Give the user clear next steps:

```
Worktree created successfully!

Location: <full-path-to-worktree>
Branch: <branch-name>
Based on: <base-branch>

To start working:
  cd <worktree-dir>

To remove this worktree later:
  git worktree remove <worktree-dir>
  # or: git worktree remove --force <worktree-dir> (if there are uncommitted changes)

To list all worktrees:
  git worktree list

To prune stale worktrees:
  git worktree prune
```

## Advanced Options

Support these optional flags if present in $ARGUMENTS:

- `--force` or `-f`: Force creation even if branch exists
- `--detach`: Create detached HEAD worktree
- `--no-checkout`: Create worktree without checking out files
- `--lock`: Lock the worktree (prevent removal)

## Common Patterns

**Pattern 1: Feature branch from main**
```bash
git worktree add -b feature/new-feature feature-new-feature main
```

**Pattern 2: Bug fix from current branch**
```bash
git worktree add -b hotfix/urgent-bug hotfix-urgent-bug HEAD
```

**Pattern 3: Checkout remote PR for review**
```bash
git fetch origin pull/123/head:pr-123
git worktree add pr-123 pr-123
```

**Pattern 4: Multiple worktrees for parallel work**
```bash
git worktree add -b feature-a feature-a main
git worktree add -b feature-b feature-b main
git worktree add -b bugfix bugfix main
```

## Safety Checks

**MANDATORY**: Ensure these safety checks pass:

1. **Branch naming**: Validate branch name doesn't contain invalid characters
2. **Directory exists**: Check if worktree directory already exists (error if so)
3. **Branch conflicts**: Check if branch already has a worktree (can't checkout same branch twice)
4. **Disk space**: Warn if disk space is low (worktree will duplicate working files)
5. **Git version**: Verify git version supports worktrees (2.5+, recommend 2.15+)

## Error Handling

**Common errors and solutions:**

**Error: "fatal: '<branch>' is already checked out at '<path>'"**
- Solution: Can't have same branch in multiple worktrees. Use different branch name or remove old worktree.

**Error: "fatal: invalid reference: <branch>"**
- Solution: Branch doesn't exist. Use `-b` to create new branch.

**Error: "fatal: '<path>' already exists"**
- Solution: Directory exists. Use different name or remove existing directory.

**Error: "fatal: not a git repository"**
- Solution: Not in a git repository. Navigate to repo root or bare repo parent.

## Bare Repository Conversion (if needed)

If user has a standard repository and wants to convert to bare repo workflow:

```bash
# WARNING: This is a significant change. Explain to user first.

# 1. Rename .git to .bare
mv .git .bare

# 2. Update bare repo config
git config --file .bare/config core.bare false

# 3. Create first worktree from current branch
git worktree add main

# 4. Update workspace
# User should move their working files to the 'main' worktree
```

**IMPORTANT**: Only suggest this conversion if user explicitly wants it. Explain it's a one-way change.

## Best Practices

- **Naming convention**: Use descriptive worktree directory names (feature-name, bugfix-issue-123)
- **Cleanup regularly**: Remove merged worktrees with `git worktree remove`
- **Shared configs**: Keep shared configurations in central location (`.claude-shared/`, etc.)
- **One branch per worktree**: Don't check out same branch in multiple worktrees
- **Prune stale**: Run `git worktree prune` periodically to clean up deleted worktree references

## Success Criteria

- New worktree directory created and populated
- Correct branch checked out in worktree
- Shared configurations properly linked (if applicable)
- User can immediately start working in the new worktree
- Clear instructions provided for next steps

Remember: Worktrees are powerful for parallel development but require understanding of the workflow. Guide users clearly through setup and usage.

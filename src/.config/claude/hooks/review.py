#!/usr/bin/env python3

import os
import json
import subprocess
from pathlib import Path

def get_current_directory():
    """Get the directory from which the script was run."""
    return os.getcwd()

def get_project_name(directory):
    """Extract project name from directory path."""
    return Path(directory).name

def get_pr_numbers():
    """Fetch PR numbers that need review."""
    try:
        result = subprocess.run(
            ['gh', 'pr', 'list', '--search', 'review-requested:@me', '--json', 'number'],
            capture_output=True,
            text=True,
            check=True
        )
        prs = json.loads(result.stdout)
        return [pr['number'] for pr in prs]
    except subprocess.CalledProcessError as e:
        print(f"Error fetching PRs: {e}")
        return []
    except json.JSONDecodeError as e:
        print(f"Error parsing PR data: {e}")
        return []

def ensure_output_directory(project_name):
    """Create output directory if it doesn't exist."""
    output_dir = Path.home() / '.local' / 'reviews' / project_name
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir

def run_claude_review(pr_number, output_file, project_dir):
    """Run Claude review command and save output."""
    try:
        result = subprocess.run(
            ['claude', '-p', f'/review {pr_number}', '--allowedTools', 'Bash', 'Read', 'Edit', 'Grep', 'Glob'],
            capture_output=True,
            text=True,
            check=True,
            cwd=project_dir
        )
        
        with open(output_file, 'w') as f:
            f.write(result.stdout)
        
        print(f"Review for PR #{pr_number} saved to {output_file}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running Claude review for PR #{pr_number}: {e}")
        return False

def main():
    current_dir = get_current_directory()
    project_name = get_project_name(current_dir)
    
    print(f"Running from: {current_dir}")
    print(f"Project name: {project_name}")
    
    pr_numbers = get_pr_numbers()
    
    if not pr_numbers:
        print("No PRs found that require your review.")
        return
    
    print(f"Found {len(pr_numbers)} PRs requiring review: {pr_numbers}")
    
    output_dir = ensure_output_directory(project_name)
    
    for pr_number in pr_numbers:
        output_file = output_dir / f"{pr_number}.md"
        print(f"Processing PR #{pr_number}...")
        run_claude_review(pr_number, output_file, current_dir)

if __name__ == "__main__":
    main()


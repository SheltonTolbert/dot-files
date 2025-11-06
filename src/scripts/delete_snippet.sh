#!/bin/bash

set -eu -o pipefail

SNIPPETS_DIR="$HOME/.dotfiles/src/scripts/snippets"

show_usage() {
    cat << EOF
Usage: $0 [name]

Delete a code snippet. If no name is provided, you'll be prompted to select one interactively using fzf.

Options:
    -h, --help    Show this help message
    --force       Skip confirmation prompt

Examples:
    $0 database_query
    $0 --force sql_example
    $0                      # Interactive selection with fzf

EOF
}

main() {
    local snippet_name=""
    local force_delete=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            --force)
                force_delete=true
                shift
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                show_usage
                exit 1
                ;;
            *)
                if [[ -n "$snippet_name" ]]; then
                    echo "Error: Multiple snippet names provided" >&2
                    exit 1
                fi
                snippet_name="$1"
                shift
                ;;
        esac
    done
    
    # Check if snippets directory exists
    if [[ ! -d "$SNIPPETS_DIR" ]]; then
        echo "Error: Snippets directory does not exist: $SNIPPETS_DIR" >&2
        exit 1
    fi
    
    # Check if there are any snippets
    if [[ -z "$(ls -A "$SNIPPETS_DIR" 2>/dev/null)" ]]; then
        echo "No snippets found to delete." >&2
        exit 1
    fi
    
    # Interactive selection if no name provided
    if [[ -z "$snippet_name" ]]; then
        if ! command -v fzf >/dev/null 2>&1; then
            echo "Error: fzf is required for interactive selection but not found" >&2
            exit 1
        fi
        
        snippet_name=$(ls "$SNIPPETS_DIR" | fzf --prompt="Select snippet to delete: " --height=40%)
        
        # Check if user cancelled selection
        if [[ -z "$snippet_name" ]]; then
            echo "No snippet selected. Aborted."
            exit 0
        fi
    fi
    
    local snippet_path="$SNIPPETS_DIR/$snippet_name"
    
    # Check if snippet exists
    if [[ ! -f "$snippet_path" ]]; then
        echo "Error: Snippet '$snippet_name' does not exist" >&2
        exit 1
    fi
    
    # Show preview and confirm deletion (unless --force)
    if [[ "$force_delete" != true ]]; then
        echo "Preview of '$snippet_name':"
        echo "----------------------------------------"
        cat "$snippet_path"
        echo "----------------------------------------"
        printf "Are you sure you want to delete snippet '%s'? (y/N): " "$snippet_name"
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                ;;
            *)
                echo "Deletion cancelled."
                exit 0
                ;;
        esac
    fi
    
    # Delete the snippet
    if rm "$snippet_path"; then
        echo "Snippet '$snippet_name' deleted successfully."
    else
        echo "Error: Failed to delete snippet '$snippet_name'" >&2
        exit 1
    fi
}

main "$@"
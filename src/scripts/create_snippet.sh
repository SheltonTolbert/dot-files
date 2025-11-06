#!/bin/bash

set -eu -o pipefail

SNIPPETS_DIR="$HOME/.dotfiles/src/scripts/snippets"

show_usage() {
    cat << EOF
Usage: $0 [name]

Create a new code snippet. If no name is provided, you'll be prompted to enter one.
The snippet content will be read from stdin or clipboard.

Options:
    -h, --help    Show this help message

Examples:
    $0 database_query
    echo "SELECT * FROM users;" | $0 sql_example
    pbpaste | $0 clipboard_content

EOF
}

main() {
    local snippet_name=""
    
    # Parse arguments
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        "")
            # Prompt for snippet name
            printf "Enter snippet name: "
            read -r snippet_name
            ;;
        *)
            snippet_name="$1"
            ;;
    esac
    
    # Validate snippet name
    if [[ -z "$snippet_name" ]]; then
        echo "Error: Snippet name cannot be empty" >&2
        exit 1
    fi
    
    # Check if snippet already exists
    local snippet_path="$SNIPPETS_DIR/$snippet_name"
    if [[ -f "$snippet_path" ]]; then
        printf "Snippet '%s' already exists. Overwrite? (y/N): " "$snippet_name"
        read -r response
        case "$response" in
            [yY]|[yY][eE][sS])
                echo "Overwriting existing snippet..."
                ;;
            *)
                echo "Aborted."
                exit 1
                ;;
        esac
    fi
    
    # Create snippets directory if it doesn't exist
    mkdir -p "$SNIPPETS_DIR"
    
    # Get content from stdin or prompt user
    if [[ ! -t 0 ]]; then
        # Content piped from stdin
        cat > "$snippet_path"
    else
        # Prompt for content
        echo "Enter snippet content (press Ctrl+D when finished):"
        cat > "$snippet_path"
    fi
    
    # Verify content was added
    if [[ ! -s "$snippet_path" ]]; then
        echo "Error: No content provided, removing empty snippet file" >&2
        rm -f "$snippet_path"
        exit 1
    fi
    
    echo "Snippet '$snippet_name' created successfully at: $snippet_path"
}

main "$@"
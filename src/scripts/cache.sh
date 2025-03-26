#!/bin/bash

# Define the cache directory
CACHE_DIR="$HOME/.tmp/cache"

# Function to write content to the cache file
write_cache() {
    local name="$1"
    # Ensure content is provided via piped input
    if [ ! -t 0 ]; then
        cat > "$CACHE_DIR/$name"
        echo "Content written to $CACHE_DIR/$name"
    else
        echo "No piped input provided. Please pipe content to be cached."
        exit 1
    fi
}

# Function to read content from the cache file
read_cache() {
    local name="$1"
    # Check if the file exists
    if [ -f "$CACHE_DIR/$name" ]; then
        cat "$CACHE_DIR/$name"
    else
        echo "File $CACHE_DIR/$name does not exist."
        exit 1
    fi
}

# If -r is passed, try to read the cache file
if [[ "$1" == "-r" ]]; then
    # Ensure the second argument (name) is provided for reading
    if [ -z "$2" ]; then
        echo "Please provide a name to read from the cache."
        exit 1
    fi
    # Read the cache file
    read_cache "$2"
else
    # If no -r flag is passed, ensure there's a name to save the cache
    if [ -z "$1" ]; then
        echo "Please provide a name to save the cache."
        exit 1
    fi

    # Check if there's piped input, and if so, write it to the cache file
    if [ ! -t 0 ]; then
        write_cache "$1"
    else
        echo "Please provide piped input to write to the cache."
        exit 1
    fi
fi


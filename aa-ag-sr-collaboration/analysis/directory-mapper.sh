#!/bin/bash

# Set starting directory (current directory if not given)
start_dir="${1:-.}"

# Recursive function to display tree
print_tree() {
    local dir="$1"
    local prefix="$2"

    # List all entries (files + directories) sorted
    local entries=("$dir"/*)
    for entry in "${entries[@]}"; do
        if [ -d "$entry" ]; then
            echo "${prefix}├── $(basename "$entry")/"
            print_tree "$entry" "$prefix│   "
        elif [ -f "$entry" ]; then
            echo "${prefix}├── $(basename "$entry")"
        fi
    done
}

# Print the root
echo "$(basename "$start_dir")/"
print_tree "$start_dir" ""


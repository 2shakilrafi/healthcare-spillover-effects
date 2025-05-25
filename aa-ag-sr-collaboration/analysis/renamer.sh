#!/bin/bash

# Set the starting directory (current directory if not given)
start_dir="${1:-.}"

# Function to transform names
transform_name() {
    local name="$1"
    # Replace spaces and underscores with hyphens
    name=$(echo "$name" | tr ' _' '-')
    # Insert hyphen between lowercase-uppercase transitions (CamelCase -> camel-case)
    name=$(echo "$name" | sed -r 's/([a-z])([A-Z])/\1-\2/g')
    # Convert to all lowercase
    name=$(echo "$name" | tr 'A-Z' 'a-z')
    echo "$name"
}

# First, rename all directories from **deepest** first
find "$start_dir" -depth -type d | while read -r dir; do
    parent=$(dirname "$dir")
    base=$(basename "$dir")

    newbase=$(transform_name "$base")

    if [[ "$base" != "$newbase" ]]; then
        mv "$dir" "$parent/$newbase"
        echo "Renamed directory: $dir -> $parent/$newbase"
    fi
done

# Now, rename all files
find "$start_dir" -type f | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")

    newbase=$(transform_name "$base")

    if [[ "$base" != "$newbase" ]]; then
        mv "$file" "$dir/$newbase"
        echo "Renamed file: $file -> $dir/$newbase"
    fi
done


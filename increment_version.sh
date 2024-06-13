#!/bin/bash

# Read the current version from the PHP file
VERSION_FILE="version.php"
if [ -f "$VERSION_FILE" ]; then
    echo "$VERSION_FILE found."
    echo "Contents of $VERSION_FILE:"
    cat "$VERSION_FILE"

    # Extract the version string
    CURRENT_VERSION=$(grep -oP "\$version\s*=\s*'\d+\.\d+\.\d+'" "$VERSION_FILE" | grep -oP "\d+\.\d+\.\d+")
    if [ -z "$CURRENT_VERSION" ]; then
        echo "Error: Failed to extract version from $VERSION_FILE. Make sure the version is in the format 'x.y.z'."
        echo "Contents of $VERSION_FILE:"
        cat "$VERSION_FILE"
        exit 1
    else
        echo "Extracted version: $CURRENT_VERSION"
    fi
else
    echo "Error: $VERSION_FILE file not found!"
    exit 1
fi

#!/bin/bash

# Fetch all tags from remote
git fetch --tags

# Get the latest tag (version)
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

# Default to v1.0.0.0 if no tags exist
if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG="v1.0.0.0"
fi

# Extract the version numbers from the tag
IFS='.' read -r -a VERSION_PARTS <<< "${LATEST_TAG:1}"

MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}
BUILD=${VERSION_PARTS[3]}

# Increment the build version
BUILD=$((BUILD + 1))

# Form the new version string
NEW_VERSION="$MAJOR.$MINOR.$PATCH.$BUILD"

# Create the new tag
NEW_TAG="v$NEW_VERSION"

# Commit and tag the new version
git config user.email "conventional.changelog.action@github.com"
git config user.name "Conventional Changelog Action"
git tag


#!/bin/bash

# Fetch all tags from remote
git fetch --tags

# Get the latest tag (version)
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

# Extract the version numbers from the tag
IFS='.' read -r -a VERSION_PARTS <<< "${LATEST_TAG:1}"

MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Increment the patch version
PATCH=$((PATCH + 1))

# Form the new version string
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Create the new tag
NEW_TAG="v$NEW_VERSION"

# Commit and tag the new version
git config user.email "conventional.changelog.action@github.com"
git config user.name "Conventional Changelog Action"
git tag -a "$NEW_TAG" -m "$NEW_TAG"
git push origin "$NEW_TAG"

# Create a new release
RELEASE_BODY=$(conventional-changelog -p angular -i CHANGELOG.md -s -r 0)
gh release create "$NEW_TAG" --notes "$RELEASE_BODY"


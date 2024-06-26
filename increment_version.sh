#!/bin/bash

set -e

# Fetch tags from the remote
git fetch --tags

# Get the latest tag
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

# If no tags are found, start from v0.1.0
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="v0.1.0"
fi

echo "Latest tag: $LATEST_TAG"

# Extract the version number components
IFS='.' read -r -a VERSION_PARTS <<< "${LATEST_TAG#v}"

MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Increment the version number (customize this logic as needed)
if [ "$MINOR" -ge "1" ]; then
  PATCH=$((PATCH + 1))
else
  MINOR=$((MINOR + 1))
  PATCH=0
fi

# Construct the new version tag
NEW_TAG="v$MAJOR.$MINOR.$PATCH"

echo "New tag: $NEW_TAG"

# Create and push the new tag
git tag $NEW_TAG
git push origin $NEW_TAG

# Create a new release
gh release create $NEW_TAG

    RELEASE_NOTES="$RELEASE_BODY"
else
    RELEASE_NOTES="$RELEASE_BODY"$'\n\n'"$COMMITS"
fi

# Create a new release with the combined notes
gh release create "$NEW_TAG" --notes "$RELEASE_NOTES"

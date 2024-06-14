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

# Update version.php with the new version
VERSION_FILE="test/.github/workflows/version.php"



# Check if version.php exists
if [ -f "$VERSION_FILE" ]; then
    echo "$VERSION_FILE found."
    # Update the version in the PHP file
    sed -i "s/\(\$version\s*=\s*'\)[vV]*[0-9]\+\.[0-9]\+\.[0-9]\+\(';.*\)/\1$NEW_VERSION\2/" "$VERSION_FILE"
    echo "Updated $VERSION_FILE with version: $NEW_VERSION"
else
    echo "Error: $VERSION_FILE not found!"
    exit 1
fi

# Commit the updated PHP file
git add "$VERSION_FILE"
git commit -m "chore: Update version to $NEW_VERSION in $VERSION_FILE"

# Determine the current branch
CURRENT_BRANCH=$(git branch --show-current)

# Push the changes to the current branch
git push origin "$CURRENT_BRANCH"

# Tag and create a new release
git tag -a "$NEW_TAG" -m "$NEW_TAG"
git push origin "$NEW_TAG"

# Create a new release
RELEASE_BODY=$(conventional-changelog -p angular -i CHANGELOG.md -s -r 0)
gh release create "$NEW_TAG" --notes "$RELEASE_BODY"

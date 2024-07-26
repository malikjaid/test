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
VERSION_FILE="version.php"

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

# Create a new branch for the version bump
BRANCH_NAME="bump-version-$NEW_VERSION"
git checkout -b "$BRANCH_NAME"

# Commit the updated PHP file
git add "$VERSION_FILE"
git commit -m "chore: Update version to $NEW_VERSION in $VERSION_FILE"

# Stash any uncommitted changes
git stash

# Pull the latest changes from the remote branch to avoid conflicts
git pull --rebase origin "$BRANCH_NAME"

# Apply the stashed changes, if any
git stash pop || true

# Push the changes to the new branch
git push origin "$BRANCH_NAME"

# Create a pull request using the GitHub CLI
gh pr create --title "Release $NEW_TAG" --body "Bump version to $NEW_VERSION" --base malikt --head "$BRANCH_NAME"

# Tag the new version (this will be done after the PR is merged)
# git tag -a "$NEW_TAG" -m "$NEW_TAG"
# git push origin "$NEW_TAG"

# Note: Uncomment the above two lines after the PR is merged


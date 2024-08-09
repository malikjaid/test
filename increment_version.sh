#!/bin/bash

# Fetch all tags from remote
git fetch --tags

# Determine the current branch
CURRENT_BRANCH=$(git branch --show-current)

# Set version file and initial version based on the branch
case "$CURRENT_BRANCH" in
    "main")
        VERSION_FILE="version-main.php"
        INITIAL_VERSION="22022.0.0"
        ;;
    "malikt")
        VERSION_FILE="version-malikt.php"
        INITIAL_VERSION=""
        ;;
    *)
        VERSION_FILE="version-$CURRENT_BRANCH.php"
        INITIAL_VERSION="9999.0.0"
        ;;
esac

# Use the initial version if specified; otherwise, continue from the latest tag
if [ -n "$INITIAL_VERSION" ]; then
    NEW_VERSION="$INITIAL_VERSION"
    INITIAL_VERSION=""  # Resetting for future runs
else
    # Get the latest tag for the current branch
    LATEST_TAG=$(git tag --list "v*" | grep "$CURRENT_BRANCH" | sort -V | tail -n1)

    if [ -z "$LATEST_TAG" ]; then
        # Initialize version if no tags exist
        MAJOR=0
        MINOR=0
        PATCH=0
    else
        # Extract the version numbers from the tag
        IFS='.' read -r -a VERSION_PARTS <<< "${LATEST_TAG:1}"

        MAJOR=${VERSION_PARTS[0]}
        MINOR=${VERSION_PARTS[1]}
        PATCH=${VERSION_PARTS[2]}
    fi

    # Increment the patch version
    PATCH=$((PATCH + 1))

    # Form the new version string
    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

# Form the new tag
NEW_TAG="v$NEW_VERSION-$CURRENT_BRANCH"

# Check if the new tag already exists and handle the error
if git rev-parse "$NEW_TAG" >/dev/null 2>&1; then
    echo "Error: Tag '$NEW_TAG' already exists."
    exit 1
fi

# Update the version file with the new version
if [ -f "$VERSION_FILE" ]; then
    echo "$VERSION_FILE found."
    # Update the version in the PHP file
    sed -i "s/\(\$version\s*=\s*'\)[vV]*[0-9]\+\.[0-9]\+\.[0-9]\+\(';.*\)/\1$NEW_VERSION\2/" "$VERSION_FILE"
    echo "Updated $VERSION_FILE with version: $NEW_VERSION"
else
    echo "Error: $VERSION_FILE not found!"
    exit 1
fi

# Commit the updated version file
git add "$VERSION_FILE"
git commit -m "chore: Update version to $NEW_VERSION in $VERSION_FILE"

# Push the changes to the current branch
git push origin "$CURRENT_BRANCH"

# Tag and create a new release
git tag -a "$NEW_TAG" -m "$NEW_TAG"
git push origin "$NEW_TAG"

# Create release notes
RELEASE_BODY=$(conventional-changelog -p angular -i CHANGELOG.md -s -r 0)

# Fetch the latest commit messages since the last tag, excluding version file updates
COMMITS=$(git log $LATEST_TAG..HEAD --pretty=format:"%h %s" --no-merges | grep -v "chore: Update version to")

# Combine the release notes and commit messages, ensuring proper formatting
if [[ -z "$COMMITS" ]]; then
    RELEASE_NOTES="$RELEASE_BODY"
else
    RELEASE_NOTES="$RELEASE_BODY"$'\n\n'"$COMMITS"
fi

# Create a new release with the combined notes
gh release create "$NEW_TAG" --notes "$RELEASE_NOTES"

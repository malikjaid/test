#!/bin/bash

# Fetch all tags from remote
git fetch --tags

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

# Extract the version numbers from the file
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"

MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

echo "Current Version Parts: MAJOR=$MAJOR, MINOR=$MINOR, PATCH=$PATCH"

# Increment the patch version
PATCH=$((PATCH + 1))

# Form the new version string
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "New Version: $NEW_VERSION"

# Update the PHP file with the new version
sed -i "s/\(\$version\s*=\s*'\)[0-9]\+\.[0-9]\+\.[0-9]\+\(';.*\)/\1$NEW_VERSION\2/" "$VERSION_FILE"

echo "Updated $VERSION_FILE contents:"
cat "$VERSION_FILE"

# Commit the updated PHP file
git config user.email "conventional.changelog.action@github.com"
git config user.name "Conventional Changelog Action"
git add "$VERSION_FILE"
git commit -m "chore(release): $NEW_VERSION"

# Create the new tag
NEW_TAG="$NEW_VERSION"
git tag -a "$NEW_TAG" -m "$NEW_TAG"
git push origin "$NEW_TAG"

# Push the changes to the repository
git push origin

# Create a new release
RELEASE_BODY=$(conventional-changelog -p angular -i CHANGELOG.md -s -r 0)
gh release create "$NEW_TAG" --notes "$RELEASE_BODY"

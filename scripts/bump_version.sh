#!/usr/bin/env bash
# Quick release helper script

set -e

echo "🚀 annotree Release Helper"
echo ""

# Check if working directory is clean
if [[ -n $(git status -s) ]]; then
    echo "❌ Working directory is not clean. Please commit or stash your changes first."
    git status -s
    exit 1
fi

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "main" ]]; then
    echo "⚠️  Warning: You are on branch '$BRANCH', not 'main'"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Ask for version bump type
echo "Select version bump type:"
echo "  1) patch (0.1.0 → 0.1.1) - bug fixes"
echo "  2) minor (0.1.0 → 0.2.0) - new features"
echo "  3) major (0.1.0 → 1.0.0) - breaking changes"
read -p "Enter choice [1-3]: " choice

case $choice in
    1) BUMP_TYPE="patch" ;;
    2) BUMP_TYPE="minor" ;;
    3) BUMP_TYPE="major" ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

# Show what will change
echo ""
echo "📋 Preview changes:"
uv run bump-my-version bump $BUMP_TYPE --dry-run

echo ""
read -p "Proceed with version bump? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Bump version
echo ""
echo "📝 Bumping version..."
uv run bump-my-version bump $BUMP_TYPE

# Get new version
NEW_VERSION=$(uv run bump-my-version show current_version)

echo ""
echo "✅ Version bumped to $NEW_VERSION"
echo ""

# Push to remote
read -p "Push commits and tags to GitHub? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⬆️  Pushing to GitHub..."
    git push
    git push --tags
    echo ""
    echo "✅ Pushed to GitHub!"
    echo ""
    echo "🎉 Next steps:"
    echo "   1. Go to: https://github.com/suecrumpler/annotree/releases/new"
    echo "   2. Select tag: v$NEW_VERSION"
    echo "   3. Add release notes"
    echo "   4. Click 'Publish release'"
    echo "   5. GitHub Actions will automatically publish to PyPI!"
else
    echo ""
    echo "📝 Don't forget to push:"
    echo "   git push && git push --tags"
    echo ""
    echo "Then create a release on GitHub:"
    echo "   https://github.com/suecrumpler/annotree/releases/new"
fi

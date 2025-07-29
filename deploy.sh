#!/bin/bash

# Career Assessment App - Deployment Script
# Builds Flutter web app and deploys to GitHub Pages via docs folder

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting deployment of Career Assessment App...${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes. Continuing deployment.${NC}"
fi

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build for web with optimizations
echo -e "${BLUE}🔨 Building Flutter web app...${NC}"
flutter build web \
    --release \
    --web-renderer canvaskit \
    --base-href "/wigu/" \
    --dart-define=FLUTTER_WEB_USE_SKIA=true

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"

# Create docs directory if it doesn't exist
echo -e "${BLUE}📁 Preparing docs directory...${NC}"
if [ -d "docs" ]; then
    rm -rf docs/*
else
    mkdir docs
fi

# Copy build output to docs folder
echo -e "${BLUE}📋 Copying build output to docs folder...${NC}"
cp -r build/web/* docs/

# Create .nojekyll file to prevent Jekyll processing
touch docs/.nojekyll

# Create custom 404.html for SPA routing
cat > docs/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>When I grow up - Career Assessment</title>
    <script type="text/javascript">
        // GitHub Pages SPA redirect
        var pathSegmentsToKeep = 1;
        var l = window.location;
        l.replace(
            l.protocol + '//' + l.hostname + (l.port ? ':' + l.port : '') +
            l.pathname.split('/').slice(0, 1 + pathSegmentsToKeep).join('/') + 
            '/?/' + 
            l.pathname.slice(1).split('/').slice(pathSegmentsToKeep).join('/').replace(/&/g, '~and~') +
            (l.search ? '&' + l.search.slice(1).replace(/&/g, '~and~') : '') +
            l.hash
        );
    </script>
</head>
<body>
    <div style="text-align: center; padding: 50px; font-family: Arial, sans-serif;">
        <h1>When I grow up...</h1>
        <p>Redirecting to career assessment...</p>
    </div>
</body>
</html>
EOF

# Add redirect script to index.html for SPA routing
echo -e "${BLUE}🔗 Adding SPA routing support...${NC}"
sed -i.bak '/<head>/a\
  <script type="text/javascript">\
    (function(l) {\
      if (l.search[1] === "/" ) {\
        var decoded = l.search.slice(1).split("&").map(function(s) {\
          return s.replace(/~and~/g, "&")\
        }).join("?");\
        window.history.replaceState(null, null,\
            l.pathname.slice(0, -1) + decoded + l.hash\
        );\
      }\
    }(window.location))\
  </script>' docs/index.html && rm docs/index.html.bak

# Update base href for GitHub Pages
sed -i.bak 's|<base href="/wigu/">|<base href="/wigu/">|g' docs/index.html && rm docs/index.html.bak

# Add deployment info
cat > docs/DEPLOYMENT_INFO.md << EOF
# Deployment Information

- **Deployed at**: $(date)
- **Git commit**: $(git rev-parse HEAD)
- **Git branch**: $(git branch --show-current)
- **Flutter version**: $(flutter --version | head -n 1)
- **Build type**: Release web build with CanvasKit renderer

## Access the app
The app is available at: https://$(git config --get remote.origin.url | sed 's|.git||' | sed 's|git@github.com:|https://github.com/|')/wigu/

## Technical details
- Single Page Application (SPA) with client-side routing
- GitHub Pages compatible with custom 404.html redirect
- CanvasKit renderer for better performance
- Local-only persistence (no cloud dependencies)
EOF

# Git operations
echo -e "${BLUE}📤 Committing and pushing to git...${NC}"

# Add all changes
git add .

# Check if there are changes to commit
if git diff --staged --exit-code > /dev/null; then
    echo -e "${YELLOW}ℹ️  No changes to commit${NC}"
else
    # Commit changes
    COMMIT_MSG="🚀 Deploy career assessment app - $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    echo -e "${GREEN}✅ Changes committed${NC}"
fi

# Push to origin
echo -e "${BLUE}⬆️  Pushing to remote repository...${NC}"
git push origin main

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to push to remote repository${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Successfully pushed to remote repository${NC}"

# Get repository info for GitHub Pages URL
REPO_URL=$(git config --get remote.origin.url)
if [[ $REPO_URL == git@github.com:* ]]; then
    GITHUB_USER=$(echo $REPO_URL | sed 's|git@github.com:||' | sed 's|/.*||' | tr '[:upper:]' '[:lower:]')
    REPO_NAME=$(echo $REPO_URL | sed 's|.*/||' | sed 's|.git||')
elif [[ $REPO_URL == https://github.com/* ]]; then
    GITHUB_USER=$(echo $REPO_URL | sed 's|https://github.com/||' | sed 's|/.*||' | tr '[:upper:]' '[:lower:]')
    REPO_NAME=$(echo $REPO_URL | sed 's|.*/||' | sed 's|.git||')
else
    GITHUB_USER="your-username"
    REPO_NAME="your-repo"
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}📍 Your app will be available at:${NC}"
echo -e "${GREEN}   https://${GITHUB_USER}.github.io/${REPO_NAME}/${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "   1. Go to your GitHub repository settings"
echo -e "   2. Navigate to 'Pages' section"
echo -e "   3. Set source to 'Deploy from a branch'"
echo -e "   4. Select 'main' branch and '/docs' folder"
echo -e "   5. Save the settings"
echo ""
echo -e "${BLUE}🔄 It may take a few minutes for GitHub Pages to update${NC}"
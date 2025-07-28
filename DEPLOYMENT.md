# Career Assessment App - Deployment Guide

This guide explains how to deploy the "When I grow up..." career assessment application to GitHub Pages.

## Quick Deployment

1. **Run the deployment script:**
   ```bash
   ./deploy.sh
   ```

2. **Configure GitHub Pages:**
   - Go to your GitHub repository settings
   - Navigate to the "Pages" section
   - Set source to "Deploy from a branch"
   - Select "main" branch and "/docs" folder
   - Save the settings

3. **Access your app:**
   - Your app will be available at: `https://[username].github.io/wigu/`
   - It may take a few minutes for GitHub Pages to update

## What the deployment script does

1. **Cleans and builds:** Runs `flutter clean`, `flutter pub get`, and builds for web
2. **Optimizes for production:** Uses release mode with CanvasKit renderer
3. **Prepares for GitHub Pages:** 
   - Copies build output to `docs/` folder
   - Sets correct base href for GitHub Pages
   - Creates `.nojekyll` file to prevent Jekyll processing
   - Adds SPA routing support with custom 404.html
4. **Commits and pushes:** Automatically commits changes and pushes to git

## Manual Deployment Steps

If you prefer to deploy manually:

### 1. Build the app
```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit --base-href "/wigu/"
```

### 2. Prepare docs folder
```bash
# Create/clean docs directory
rm -rf docs/
mkdir docs/

# Copy build output
cp -r build/web/* docs/

# Prevent Jekyll processing
touch docs/.nojekyll
```

### 3. Configure for SPA routing
Create `docs/404.html` for client-side routing support (see deploy script for content).

### 4. Commit and push
```bash
git add .
git commit -m "Deploy career assessment app"
git push origin main
```

## Configuration Options

### Base URL
The app is configured to deploy at `/wigu/` path. To change this:
1. Update `--base-href` in the build command
2. Update the redirect logic in 404.html
3. Update the base href replacement in the deploy script

### Build Options
- **Renderer**: Uses CanvasKit for better performance
- **Mode**: Release mode for optimized builds
- **Base href**: Set to `/wigu/` for GitHub Pages

## Troubleshooting

### Build fails
- Ensure all dependencies are available: `flutter pub get`
- Check Flutter version compatibility
- Verify no compilation errors: `flutter analyze`

### App doesn't load on GitHub Pages
- Verify GitHub Pages is configured to use `main` branch and `/docs` folder
- Check that base href matches your repository name
- Ensure `.nojekyll` file exists in docs folder

### SPA routing doesn't work
- Verify 404.html is present in docs folder
- Check that the redirect script is properly added to index.html
- Ensure base href is correctly set

## Technical Details

### App Architecture
- **Frontend**: Flutter web application
- **Persistence**: Local-only using Hive (no cloud dependencies)
- **AI Integration**: OpenAI API for career insights
- **Routing**: Client-side routing with fallback support

### Security
- All user data stays local (GDPR compliant)
- No user authentication required
- AI API calls are the only external dependency

### Performance
- CanvasKit renderer for smooth animations
- Tree-shaking enabled to reduce bundle size
- Optimized for web performance

## GitHub Pages Setup

1. **Repository Settings > Pages**
2. **Source**: Deploy from a branch
3. **Branch**: main
4. **Folder**: /docs
5. **Custom domain** (optional): Set if you have one

The app will be available at `https://[username].github.io/[repository-name]/`

## Updates and Maintenance

To update the deployed app:
1. Make your changes to the Flutter code
2. Test locally: `flutter run -d chrome`
3. Deploy: `./deploy.sh`

The script handles versioning and maintains deployment history through git commits.
# Manual Deployment Instructions

Since the shell environment seems to have issues, here are the manual steps to deploy:

## Build the app
```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit --base-href "/wigu/"
```

## Copy to docs folder
```bash
rm -rf docs/*
cp -r build/web/* docs/
touch docs/.nojekyll
```

## Commit and push
```bash
git add .
git commit -m "🚀 Fix web deployment with better error handling

- Add web-specific Hive initialization
- Improve error handling and user feedback
- Add detailed error screens for debugging
- Handle initialization failures gracefully"
git push origin main
```

## The issue was likely:
1. **Hive initialization failing on web** - Fixed with web-specific init
2. **Missing error handling** - Now shows detailed error screens
3. **JavaScript console errors** - Better error boundaries added

## Expected URL:
https://wittering.github.io/wigu/

## GitHub Pages Setup:
1. Go to repository settings
2. Navigate to Pages section  
3. Set source to "Deploy from a branch"
4. Select "main" branch and "/docs" folder
5. Save settings

The app should now work or at least show helpful error messages if something is still wrong.
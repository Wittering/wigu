# Cache Fix for GitHub Pages Deployment

The 404 errors you're seeing are likely due to:

1. **Browser caching old version** - Clear browser cache completely
2. **Service worker cache** - The service worker might be serving old cached responses
3. **GitHub Pages propagation delay** - Changes might not be fully deployed yet

## Quick fixes to try:

### 1. Hard refresh the page
- Chrome/Firefox: Ctrl+Shift+R (Cmd+Shift+R on Mac)
- Or open developer tools and right-click refresh button → "Empty Cache and Hard Reload"

### 2. Clear service worker cache
1. Open browser developer tools (F12)
2. Go to Application tab
3. Click "Service Workers" 
4. Find your app and click "Unregister"
5. Go to "Storage" tab
6. Click "Clear site data"

### 3. Check if files load directly
Try accessing these URLs directly:
- https://wittering.github.io/wigu/favicon.png
- https://wittering.github.io/wigu/manifest.json

If they return 404, the deployment didn't work correctly.
If they load fine, it's a caching/service worker issue.

### 4. GitHub Pages troubleshooting
- Check repository Settings → Pages to ensure it's set to deploy from `main` branch `/docs` folder
- Wait 5-10 minutes for changes to propagate
- Check if there were any deployment errors in the Actions tab

The SPA redirect script I just added should help with routing issues, but the static asset 404s suggest a caching problem.
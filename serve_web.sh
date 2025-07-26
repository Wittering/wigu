#!/bin/bash

# Simple script to serve the Flutter web build
echo "Building Flutter web app..."
flutter build web

echo "Starting web server on http://localhost:8080"
echo "Press Ctrl+C to stop the server"

# Use Python's built-in HTTP server to serve the web build
cd build/web && python3 -m http.server 8080
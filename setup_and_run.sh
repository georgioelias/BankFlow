#!/bin/bash

# Script to setup Flutter dependencies and run the app
# This will be executed once Flutter installation completes

cd "/Users/georgioelias/Documents/Mobile Banking app"

# Find Flutter installation
if [ -d "/opt/homebrew/Caskroom/flutter" ]; then
    FLUTTER_BIN=$(find /opt/homebrew/Caskroom/flutter -name "flutter" -type f -executable 2>/dev/null | head -1)
    if [ -n "$FLUTTER_BIN" ]; then
        export PATH="$(dirname $FLUTTER_BIN):$PATH"
    fi
elif [ -d "$HOME/flutter" ]; then
    export PATH="$HOME/flutter/bin:$PATH"
fi

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed or not in PATH"
    echo "Please wait for Flutter installation to complete, then run this script again"
    exit 1
fi

echo "Flutter version:"
flutter --version

echo ""
echo "Getting Flutter dependencies..."
flutter pub get

echo ""
echo "Checking Flutter doctor..."
flutter doctor

echo ""
echo "Running the app..."
flutter run

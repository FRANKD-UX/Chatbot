#!/bin/bash

echo "Testing Flutter Homework App"
echo "============================="

# Check if Flutter is available
if ! command -v /home/ubuntu/flutter/bin/flutter &> /dev/null; then
    echo "Flutter not found. Please install Flutter first."
    exit 1
fi

# Navigate to the Flutter app directory
cd /home/ubuntu/homework_app

echo "1. Running Flutter doctor..."
/home/ubuntu/flutter/bin/flutter doctor

echo ""
echo "2. Getting dependencies..."
/home/ubuntu/flutter/bin/flutter pub get

echo ""
echo "3. Running Flutter analyze..."
/home/ubuntu/flutter/bin/flutter analyze

echo ""
echo "4. Running Flutter test..."
/home/ubuntu/flutter/bin/flutter test

echo ""
echo "5. Building Flutter app for web..."
/home/ubuntu/flutter/bin/flutter build web

echo ""
echo "Flutter app testing completed!"
echo "The app can be run with: flutter run -d web-server --web-port 8080"


#!/bin/bash
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable
fi
echo "Enabling Flutter Web..."
./flutter/bin/flutter config --enable-web
echo "Building Flutter Web App..."
./flutter/bin/flutter build web --release

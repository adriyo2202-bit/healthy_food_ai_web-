#!/bin/bash
if [ ! -f "flutter/bin/flutter" ]; then
  echo "Cloning Flutter..."
  rm -rf flutter
  git clone https://github.com/flutter/flutter.git -b stable
fi
echo "Enabling Flutter Web..."
./flutter/bin/flutter config --enable-web
echo "Building Flutter Web App..."
./flutter/bin/flutter build web --release

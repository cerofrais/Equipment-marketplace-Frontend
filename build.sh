#!/bin/bash

# Build script for EquipVerse Flutter App
# Usage: ./build.sh [android|web|both]

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to build Android
build_android() {
    print_info "Building Android APK..."
    flutter clean
    flutter pub get
    flutter build apk --release
    
    if [ $? -eq 0 ]; then
        print_success "Android APK build completed!"
        print_info "APK location: build/app/outputs/flutter-apk/app-release.apk"
    else
        print_error "Android build failed!"
        exit 1
    fi
}

# Function to build Android App Bundle (for Play Store)
build_android_bundle() {
    print_info "Building Android App Bundle..."
    flutter clean
    flutter pub get
    flutter build appbundle --release
    
    if [ $? -eq 0 ]; then
        print_success "Android App Bundle build completed!"
        print_info "App Bundle location: build/app/outputs/bundle/release/app-release.aab"
    else
        print_error "Android App Bundle build failed!"
        exit 1
    fi
}

# Function to build Web
build_web() {
    print_info "Building Web App..."
    flutter clean
    flutter pub get
    flutter build web --release
    
    if [ $? -eq 0 ]; then
        print_success "Web build completed!"
        print_info "Web build location: build/web/"
    else
        print_error "Web build failed!"
        exit 1
    fi
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Main script logic
case "$1" in
    android)
        build_android
        ;;
    android-bundle|appbundle)
        build_android_bundle
        ;;
    web)
        build_web
        ;;
    both)
        build_android
        echo ""
        build_web
        ;;
    all)
        build_android
        echo ""
        build_android_bundle
        echo ""
        build_web
        ;;
    *)
        echo "Usage: $0 [android|android-bundle|web|both|all]"
        echo ""
        echo "Options:"
        echo "  android          - Build Android APK (release)"
        echo "  android-bundle   - Build Android App Bundle for Play Store (release)"
        echo "  web              - Build Web App (release)"
        echo "  both             - Build both Android APK and Web"
        echo "  all              - Build Android APK, App Bundle, and Web"
        exit 1
        ;;
esac

#!/bin/bash
set -e

# Configuration
OLD_APP_NAME="hiddify"
NEW_APP_NAME="stk_vpn"
OLD_PKG="app.hiddify.com"
NEW_PKG="com.stkvpn.app"
OLD_DISPLAY_NAME="Hiddify"
NEW_DISPLAY_NAME="STK VPN"

echo "==> STK VPN rebranding started"

# Function to safely replace text in files if they exist
safe_replace() {
    local search=$1
    local replace=$2
    local file=$3
    if [ -f "$file" ]; then
        sed -i "s/$search/$replace/g" "$file"
    fi
}

# Function to replace in multiple files matching a pattern
safe_replace_many() {
    local search=$1
    local replace=$2
    local pattern=$3
    find . -type f -name "$pattern" -not -path "*/.*" -exec sed -i "s/$search/$replace/g" {} +
}

echo "==> Updating pubspec.yaml"
safe_replace "name: $OLD_APP_NAME" "name: $NEW_APP_NAME" "pubspec.yaml"
safe_replace "description:.*" "description: STK VPN - Personal Custom Build" "pubspec.yaml"

echo "==> Updating Android applicationId/namespace references"
safe_replace_many "$OLD_PKG" "$NEW_PKG" "build.gradle"
safe_replace_many "$OLD_PKG" "$NEW_PKG" "AndroidManifest.xml"
safe_replace_many "$OLD_PKG" "$NEW_PKG" "*.kt"
safe_replace_many "$OLD_PKG" "$NEW_PKG" "*.java"

echo "==> Updating Brand Names in code"
find . -type f -name "*.dart" -not -path "*/.*" -exec sed -i "s/$OLD_DISPLAY_NAME/$NEW_DISPLAY_NAME/g" {} +

echo "==> Rebranding complete"

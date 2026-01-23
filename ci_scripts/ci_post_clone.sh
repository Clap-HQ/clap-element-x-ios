#!/bin/sh
set -e

source ci_common.sh

setup_xcode_cloud_environment

install_xcode_cloud_brew_dependencies

# Set build number (YYMMDDHHMM format) in project.yml before xcodegen
BUILD_NUMBER=$(date +%y%m%d%H%M)
echo "🔢 Setting build number to: $BUILD_NUMBER"

# Update CURRENT_PROJECT_VERSION in project.yml
sed -i '' "s/CURRENT_PROJECT_VERSION: .*/CURRENT_PROJECT_VERSION: $BUILD_NUMBER/" project.yml

# Verify the change
echo "📋 Verifying project.yml:"
grep "CURRENT_PROJECT_VERSION" project.yml

# Generate Xcode project
echo "🔧 Running XcodeGen..."
xcodegen

# Double-check with agvtool
echo "📋 Current version after xcodegen:"
agvtool what-version

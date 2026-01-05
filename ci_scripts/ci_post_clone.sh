#!/bin/sh
set -e

source ci_common.sh

setup_xcode_cloud_environment

install_xcode_cloud_brew_dependencies

# Set build number (YYMMDDHHMM format)
BUILD_NUMBER=$(date +%y%m%d%H%M)
echo "🔢 Setting build number to: $BUILD_NUMBER"
sed -i '' "s/CURRENT_PROJECT_VERSION: .*/CURRENT_PROJECT_VERSION: $BUILD_NUMBER/" project.yml

# Generate Xcode project
echo "🔧 Running XcodeGen..."
xcodegen

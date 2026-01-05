#!/bin/sh

setup_xcode_cloud_environment () {
    set -eEu

    # Move to the project root
    cd ..
}

install_xcode_cloud_brew_dependencies () {
    brew install xcodegen
}

#!/bin/sh
set -e

# Generate TestFlight "What to Test" notes with build timestamp
if [ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]; then
    BUILD_TIME=$(date "+%Y-%m-%d %H:%M:%S KST")

    mkdir -p TestFlight
    cat > TestFlight/WhatToTest.en-US.txt << EOF
Build Time: $BUILD_TIME
Branch: $CI_BRANCH
Commit: $CI_COMMIT
EOF

    echo "✅ TestFlight notes created with build time: $BUILD_TIME"
fi

echo "✅ Build completed successfully"

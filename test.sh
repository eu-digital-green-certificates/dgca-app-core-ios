#!/bin/bash

cd "$(dirname "$0")/Tests/SwiftDGCTests"
[ -d dgc-testdata ] && rm -rf dgc-testdata
git clone https://github.com/eu-digital-green-certificates/dgc-testdata
swift test

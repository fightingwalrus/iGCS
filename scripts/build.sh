#!/usr/bin/env bash

PROJECT_ROOT=$(git rev-parse --show-toplevel)

cd $PROJECT_ROOT

xcodebuild -project iGCS.xcodeproj -sdk iphoneos7.1 clean -scheme iGCS archive -xcconfig $PROJECT_ROOT/dependencies/privateConfig.xcconfig


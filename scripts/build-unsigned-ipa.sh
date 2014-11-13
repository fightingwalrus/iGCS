#!/usr/bin/env bash

# The MIT License (MIT)
# 
# Copyright (c) 2014 Fighting Walrus LLC
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

UPDATE_DEPENDS_SCRIPT="$PROJECT_ROOT/scripts/updatedepends.sh"

# make sure private build dependencies are up to date
source $UPDATE_DEPENDS_SCRIPT

cd "$PROJECT_ROOT"

#commit version bump
APP_FULL_VERSION_NAME="$(agvtool mvers -terse1 | tail -1)-beta.$(agvtool vers -terse)"

CURRENT_GIT_HASH="$(git rev-parse --short HEAD)"
CURRENT_GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

ARCHIVE_NAME="igcs-app-build-$(agvtool vers -terse)"
ARCHIVE_PATH="$PROJECT_ROOT/build/$ARCHIVE_NAME"

echo "Building and archiving"
xcodebuild -project iGCS.xcodeproj -sdk iphoneos8.1 clean \
-scheme iGCS archive -xcconfig "$PROJECT_ROOT/dependencies/privateConfig.xcconfig" -archivePath "$ARCHIVE_PATH"
echo "Done building and archiving"

if [ -d "$ARCHIVE_PATH.xcarchive" ]; then

echo "Creating ipa file"
IPA_FILE="$ARCHIVE_PATH.ipa"

DSYM_DIR="$ARCHIVE_PATH.xcarchive/dSYMs/"
DYSM_FILE_NAME="iGCS.app.dSYM"
DSYM_FILE_PATH="$DSYM_DIR/$DYSM_FILE_NAME"

xcrun -sdk iphoneos8.1 PackageApplication -v "$ARCHIVE_PATH.xcarchive/Products/Applications/iGCS.app" \
-o "$IPA_FILE"

else
echo "$ARCHIVE_NAME.xcarchive does not exist."
fi
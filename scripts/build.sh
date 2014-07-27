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
ARCHIVE_NAME=igcs-app
ARCHIVE_PATH="$PROJECT_ROOT/build/$ARCHIVE_NAME"

# "iPhone Distribution: Fighting Walrus, LLC (V69******N)"
# use SHA-1 for codesign -s instead of name to avoid 
# issues when multiple certs with similar or the same name
# exist on the system.
SIGNING_IDENTITY="89632EFC233C40AF85B9FB45634F8601266031AF"
AD_HOC_PROVISION_FILE="$PROJECT_ROOT/dependencies/iGCS__Ad_hoc.mobileprovision"

cd $PROJECT_ROOT

echo "Building and archiving"
# pipe output from xcodebuild to dev null, should still see std error.
xcodebuild -project iGCS.xcodeproj -sdk iphoneos7.1 clean \
-scheme iGCS archive -xcconfig "$PROJECT_ROOT/dependencies/privateConfig.xcconfig" -archivePath "$ARCHIVE_PATH"
echo "Done archiving"

echo "Signing app $ARCHIVE_PATH.xcarchive"
codesign -s "$SIGNING_IDENTITY" "$ARCHIVE_PATH.xcarchive"

if [ -d "$ARCHIVE_PATH.xcarchive" ]; then
  
echo "Creating ipa file"
if [ -e "$AD_HOC_PROVISION_FILE" ]; then
IPA_FILE="$ARCHIVE_PATH.ipa"
xcrun -sdk iphoneos7.1 PackageApplication -v "$ARCHIVE_PATH.xcarchive/Products/Applications/iGCS.app" \
-o "$IPA_FILE" --embed "$AD_HOC_PROVISION_FILE"
else
echo "Missing provisioning profile: $AD_HOC_PROVISION_FILE"
fi

else
echo "$ARCHIVE_NAME.xcarchive does not exist."
fi

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

# "iPhone Distribution: Fighting Walrus, LLC (V69******N)"
# use SHA-1 for codesign -s instead of name to avoid 
# issues when multiple certs with similar or the same name
# exist on the system.
SIGNING_IDENTITY="89632EFC233C40AF85B9FB45634F8601266031AF"
AD_HOC_PROVISION_FILE="$PROJECT_ROOT/dependencies/iGCS__Ad_hoc.mobileprovision"

API_KEYS_FILE="$PROJECT_ROOT/dependencies/apikeys.txt"
UPDATE_DEPENDS_SCRIPT="$PROJECT_ROOT/scripts/updatedepends.sh"

# make sure private build dependencies are up to date
source $UPDATE_DEPENDS_SCRIPT

if [ -e "$API_KEYS_FILE" ]; then
source $API_KEYS_FILE
echo "HOCKEY API TOKEN: $HOCKEYAPP_IGCS_BETA_API_TOKEN"
echo "HOCKEY APP ID: $HOCKEYAPP_IGCS_BETA_APP_ID"
fi

cd "$PROJECT_ROOT"

# https://gist.github.com/cjus/1047794
# jsonValue() credit Tayyab Khan (itstayyab)
function jsonValue() {
  KEY=$1
  awk -F"[,:}]" '{for(i=1;i<=NF;i++) {if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n 1p
}

# bump version taking into account latest version up on hockeyapp.net
CURRENT_APP_VERSION=$(agvtool vers -terse)
if [ $HOCKEYAPP_IGCS_BETA_API_TOKEN ]; then
HOCKEY_IGCS_BETA_APP_LATEST_VERSION="$(curl -H "X-HockeyAppToken: $HOCKEYAPP_IGCS_BETA_API_TOKEN" \
"https://rink.hockeyapp.net/api/2/apps/$HOCKEYAPP_IGCS_BETA_APP_ID/app_versions?page=1" | \
jsonValue version)"

echo $HOCKEY_IGCS_BETA_APP_LATEST_VERSION

if [ $HOCKEY_IGCS_BETA_APP_LATEST_VERSION -ge $CURRENT_APP_VERSION ]; then
  echo "Hockey version is greater than local version number"
  # agvtool new-version -all 
  NEW_APP_VERSION=$(($HOCKEY_IGCS_BETA_APP_LATEST_VERSION + 1))
  echo "new version: $NEW_APP_VERSION"
  agvtool new-version -all $NEW_APP_VERSION
else
  echo "Hockeyapp not greater than local version number. Bumping local target version number."
  agvtool bump -all
fi

else
  echo "No access to hockeyapp.net, bumping local target version numbers."
  agvtool bump -all
fi

#commit version bump
APP_FULL_VERSION_NAME="$(agvtool mvers -terse1 | tail -1)-$(agvtool vers -terse)"
git commit -am "Bump version to $(agvtool vers -terse)"

git tag -am "Auto version bump and tag during build" "v$APP_FULL_VERSION_NAME" 

CURRENT_GIT_HASH="$(git rev-parse --short HEAD)"
CURRENT_GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

#push version bump and tag
git push origin $CURRENT_GIT_BRANCH --tag

ARCHIVE_NAME="igcs-app-build-$(agvtool vers -terse)"
ARCHIVE_PATH="$PROJECT_ROOT/build/$ARCHIVE_NAME"

echo "Building and archiving"
xcodebuild -project iGCS.xcodeproj -sdk iphoneos7.1 clean \
-scheme iGCS archive -xcconfig "$PROJECT_ROOT/dependencies/privateConfig.xcconfig" -archivePath "$ARCHIVE_PATH"
echo "Done building and archiving"

echo "Signing app $ARCHIVE_PATH.xcarchive"
codesign -s "$SIGNING_IDENTITY" "$ARCHIVE_PATH.xcarchive"

if [ -d "$ARCHIVE_PATH.xcarchive" ]; then
  
echo "Creating ipa file"
if [ -e "$AD_HOC_PROVISION_FILE" ]; then
IPA_FILE="$ARCHIVE_PATH.ipa"

DSYM_DIR="$ARCHIVE_PATH.xcarchive/dSYMs/"
DYSM_FILE_NAME="iGCS.app.dSYM"
DSYM_FILE_PATH="$DSYM_DIR/$DYSM_FILE_NAME"

xcrun -sdk iphoneos7.1 PackageApplication -v "$ARCHIVE_PATH.xcarchive/Products/Applications/iGCS.app" \
-o "$IPA_FILE" --embed "$AD_HOC_PROVISION_FILE"

cd "$DSYM_DIR"
zip -r "$DYSM_FILE_NAME.zip" "$DYSM_FILE_NAME"

#upload ipa and zipped dSYM file to hockeyapp.net
if [ -e "$IPA_FILE" ]; then

curl \
  -F "status=2" \
  -F "notify=0" \
  -F "mandatory=0" \
  -F "notes=Uploaded by build script - (branch: $CURRENT_GIT_BRANCH git hash: $CURRENT_GIT_HASH)" \
  -F "notes_type=0" \
  -F "ipa=@$IPA_FILE" \
  -F "dsym=@$DYSM_FILE_NAME.zip" \
  -H "X-HockeyAppToken: $HOCKEYAPP_IGCS_BETA_API_TOKEN" \
  https://rink.hockeyapp.net/api/2/apps/upload
else
  echo "No ipa file. Can't upload to hockeyapp.net"
fi

else
echo "Missing provisioning profile: $AD_HOC_PROVISION_FILE"
fi

else
echo "$ARCHIVE_NAME.xcarchive does not exist."
fi


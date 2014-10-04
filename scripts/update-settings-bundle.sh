#!/bin/bash

# Read the short version string from info.plist and
# use the value to update the Version number in our
# Settings.bundle Root plist

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
PLIST_FILE="$PROJECT_ROOT/iGCS/iGCS-Info.plist"
SHORT_VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$PLIST_FILE")"
BUNDLE_VERSION="$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST_FILE")"

/usr/libexec/PlistBuddy "$PROJECT_ROOT/iGCS/Settings.bundle/Root.plist" -c "set PreferenceSpecifiers:0:DefaultValue $SHORT_VERSION \($BUNDLE_VERSION\)"

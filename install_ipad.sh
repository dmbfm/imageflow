#!/usr/bin/env bash
xcodebuild -workspace imageflow.xcworkspace \
                 -scheme ImageFlowIPad \
                 -configuration Debug \
                 -destination 'id=00008101-00151DE20A9BA01E' \
                 -derivedDataPath ./.derived-data \
                 build


if [ $? -eq 0 ]; then
  ios-deploy --bundle ./.derived-data/Build/Products/Debug-iphoneos/ImageFlowIPad.app
fi

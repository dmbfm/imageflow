 xcodebuild -workspace imageflow.xcworkspace -scheme "ImageFlowMac" -configuration Debug -destination 'platform=macOS,arch=arm64' -derivedDataPath .build
 open ./.build/Build/Products/Debug/Image\ Flow.app

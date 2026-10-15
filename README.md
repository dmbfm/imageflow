# ImageFlow

ImageFlow is an open-source node-based image editor for macOS, built for nonlinear and non-destructive workflows.

[![Swift](https://github.com/dmbfm/imageflow/actions/workflows/swift.yml/badge.svg)](https://github.com/dmbfm/imageflow/actions/workflows/swift.yml)
[![NO AI](https://raw.githubusercontent.com/nuxy/no-ai-badge/master/badge.svg)](https://github.com/nuxy/no-ai-badge)

![ImageFlow Screenshot](https://github.com/user-attachments/assets/7a3b8fa8-e252-402c-878e-c6acc4e88e1a)

# AI Policy

AI-assisted contributions of any kind are not welcome on this repository and will not be accepted.

# Installation

<!-- Via Homebrew: -->
<!-- ``` -->
<!-- brew install --cask imageflow -->
<!-- ``` -->

<!-- You can also download the app at the app store: https://apps.apple.com/us/app/imageflow-node-image-editor/id6802113146, or directly from the [releases page](https://github.com/dmbfm/imageflow/releases). -->

You download the latest prebuilt version app at the app store: https://apps.apple.com/us/app/imageflow-node-image-editor/id6802113146, or directly from the [releases page](https://github.com/dmbfm/imageflow/releases).

# Features

- Node-based user interface.
- 100% macOS-native, document-based, swift app.
- Nonlinear and non-destructive image editing workflows.
- Large node library with more than 200 available nodes. Check the [docs](https://docs.imageflowapp.com) for a full list.
- GPU accelerated real-time previews for all image nodes.

Watch our [announcement video](https://www.youtube.com/watch?v=37z2xt8oOsE) to see some of the app's features in action!

# Usage

Check our [documentation](https://docs.imageflowapp.com) site for detailed info on the app's usage.


# Building

To build **ImageFlow** to run locally in you machine, you can simply open the `./ImageFlowMac/ImageFlowMac.xcodeproj` project on Xcode and build (or run) the `ImageFlowMacOS-Local` target. This target is configured to be signed to run locally, so you don't need to worry about code-signing or having an apple developer account.

# Contributing

Pull-requests about Localization, optimizations, bug-fixes, and other back-end features are welcome. Contributions affecting user facing features need to be heavily discussed beforehand, since maintaining a great and consistent user experience is essential. Feel free to open an issue in this case.

As noted above AI contributions are not welcome, neither is any form of LLM-generated text in issues and other discussions. 


# Acknowledgments

We are thankful for the following open-source projects which allow this app to exist:

- The [SwiftGraph](https://github.com/davecom/SwiftGraph) library developed by [David Kopec](https://davekopec.com/). 
- The [Swift CIKernel Plugin](https://github.com/in2core/swift-cikernel-plugin) library developed by [Michal Tomlein](https://github.com/michal-tomlein).
- The [Easing](https://github.com/manuelCarlos/Easing) library developed by [Manuel Carlos](https://github.com/manuelCarlos).

<p align="center">
<img width="128" height="128" alt="Image" src="https://github.com/user-attachments/assets/fdd3faff-2a37-491b-af23-0aa7220f2905" />
</p>

<p align="center">
App Icon design by <a href="https://www.matthewskiles.com/">Matthew Skiles</a>.
</p>

#if canImport(AppKit)

import SwiftUI
import AppKit
import Logging
import UniformTypeIdentifiers
import CommonUtils

import enum Models.Action

public struct ImageFlowApp: App {

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: { ImageFlowDocument() }) { configuration in
            DocumentView(configuration.document)
        }
        .defaultWindowPlacement { root, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(.suppressed)

        WelcomeWindow("Image Flow")
            .defaultLaunchBehavior(.presented)
    }
}



#endif  // canImport(AppKit)

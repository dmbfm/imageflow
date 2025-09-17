#if canImport(AppKit)

import SwiftUI
import AppKit

public struct ImageFlowApp: App {

    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    public init() {
        _ = NSDocumentController.shared
    }

    public var body: some Scene {
        Group {
            WelcomeWindow("Image Flow")

            Window("dummy", id: "dummy-window") {}
                .commands { MenuCommands() }
        }
    }
}

#endif  // canImport(AppKit)

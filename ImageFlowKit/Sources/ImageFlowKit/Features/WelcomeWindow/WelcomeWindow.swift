#if canImport(AppKit)

import SwiftUI
import AppKit

struct WelcomeWindow: Scene {

    let title: String

    func onAppear() {
        if let window = NSApp.windows.first(where: {
            $0.identifier?.rawValue == WindowID.welcome.rawValue
        }) {
            window.styleMask.insert(.fullSizeContentView)
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true

            // NOTE: This seems to fix the issue of the welcome window
            // showing up when the application is restored by macos
            // (e.g., when you stop and the run the app on Xcode)
            if !NSDocumentController.shared.documents.isEmpty {
                window.close()
            }
        }
    }

    init(_ title: String) {
        self.title = title
    }

    var body: some Scene {
        Window(title, id: WindowID.welcome.rawValue) {
            WelcomeWindowView()
                .task {
                    self.onAppear()
                }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

#endif

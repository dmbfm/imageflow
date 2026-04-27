#if canImport(AppKit)

import SwiftUI
import AppKit
import SharedModels
import SettingsFeature
import Logging

public struct WelcomeWindow: Scene {

    @AppStorage(.settingsColorSchemeKey) var cs: PreferredColorScheme = .system

    @State var recentDocuments: [RecentDocumentItem] = []

    let title: String

    func onAppear() {
        if let window = NSApp.windows.first(where: {
            $0.identifier?.rawValue == WindowID.welcome.rawValue
        }) {
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isMovableByWindowBackground = true
            window.toolbar = .init()
            window.toolbar?.isVisible = false
            // NOTE: This seems to fix the issue of the welcome window
            // showing up when the application is restored by macos
            // (e.g., when you stop and the run the app on Xcode)
            if !NSDocumentController.shared.documents.isEmpty {
                window.close()
            }

            for url in NSDocumentController.shared.recentDocumentURLs {
                if !FileManager.default.fileExists(atPath: url.path()) {
                    continue
                }
                let name = url.deletingPathExtension().lastPathComponent
                let path = url.deletingLastPathComponent().path().trimmingSuffix("/")
                self.recentDocuments.append(.init(url: url, name: name, path: path))
            }
        }
    }

    public init(_ title: String) {
        self.title = title
    }

    public var body: some Scene {
        Window(title, id: WindowID.welcome.rawValue) {
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                WelcomeWindowView(recentDocuments: self.recentDocuments)
                    .ignoresSafeArea(.all, edges: [.top, .bottom])
            }
            .frame(width: 740, height: 380 + 14)
            .preferredColorScheme(self.cs.value)
            .task {
                self.onAppear()
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

#endif

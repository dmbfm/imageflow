//
//  ImageFlowApp.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import AssetManager
import Controls
import FlowDocument
import Helpers
import Logging
import MainViewFeature
import SettingsFeature
import SharedModels
import SwiftUI
import UniformTypeIdentifiers
import WelcomeWindow

#if canImport(AppKit)
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSStandardKeyBindingResponding {

    @ActiveViewObject(GlobalCoordinator.self) var coordinator

    func selectAll(_ sender: Any?) {
        self.coordinator?.perform(userAction: .selectAllNodes)
    }

    func applicationWillTerminate(_ notification: Notification) {
        log("Removing temporary files...", level: .info)
        do {
            let url: URL = .tempAssetsDirectory
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            log("Error: \(error)", level: .error)
        }
    }

}
#endif

public struct ImageFlowApp: App {

    #if canImport(AppKit)
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    @AppStorage(.settingsColorSchemeKey) var preferredColorScheme: PreferredColorScheme = .system

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: { FlowDocument() }) { configuration in
            MainView(
                document: configuration.document,
                documentInfo: .init(id: configuration.document.id, url: configuration.fileURL)
            )
            .preferredColorScheme(self.preferredColorScheme.value)
            #if os(macOS)
            .windowTransparentTitlebar()
            #endif
        }
        #if os(macOS)
        .defaultWindowPlacement { _, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(RunConfiguration.showWelcomeWindow ? .suppressed : .automatic)
        .commands {
            // SidebarCommands()
            // InspectorCommands()
            // PreviewFeatureCommands()
            // ZoomCommands()
            // NodeEditCommands()
        }
        #else
        .commands {
            PreviewFeatureCommands()
            ZoomCommands()
            NodeEditCommands()
            PasteboardCommands()
        }
        #endif

        #if os(iOS)
        /// NOTE: We need this to avoid two title bars appearing
        DocumentGroupLaunchScene {}
        #endif

        #if os(macOS)
        WelcomeWindow("Image Flow")
            .defaultLaunchBehavior(RunConfiguration.showWelcomeWindow ? .presented : .suppressed)

        Settings {
            SettingsFeatureView()
                .preferredColorScheme(self.preferredColorScheme.value)
        }
        #endif
    }
}

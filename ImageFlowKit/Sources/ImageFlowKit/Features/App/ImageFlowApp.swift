//
//  ImageFlowApp.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Controls
import Logging
import SwiftUI
import UniformTypeIdentifiers

#if canImport(AppKit)
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        log("Removing temporary files...")
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

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: { FlowDocument() }) { configuration in
            MainView(
                document: configuration.document,
                documentInfo: .init(id: configuration.document.id, url: configuration.fileURL)
            )
            #if os(macOS)
            .windowTransparentTitlebar()
            #endif
        }
        #if os(macOS)
        .defaultWindowPlacement { root, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(RunConfiguration.showWelcomeWindow ? .suppressed : .automatic)
        .commands {
            SidebarCommands()
            PreviewFeatureCommands()
            NodeEditCommands()
        }
        #else
        .commands {
            PreviewFeatureCommands()
            NodeEditCommands()
        }
        #endif

        #if os(iOS)
        /// NOTE: We need this to avoid two title bars appearing
        DocumentGroupLaunchScene {}
        #endif

        #if os(macOS)
        WelcomeWindow("Image Flow")
            .defaultLaunchBehavior(RunConfiguration.showWelcomeWindow ? .presented : .suppressed)
        #endif
    }
}

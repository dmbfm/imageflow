//
//  ImageFlowApp.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Controls
//import AppKit
import Logging
import SwiftUI
import UniformTypeIdentifiers

//import CommonUtils

//import enum Models.Action

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

struct PreviewFeatureCommands: Commands {

    @FocusedValue(PreviewFeatureState<Flow, AssetStore>.self) var previewState: PreviewFeatureState<Flow, AssetStore>?

    var body: some Commands {
        if let previewState = self.previewState {

            @Bindable var p = previewState

            CommandGroup(after: .sidebar) {
                Section {
                    Picker(selection: $p.previewPosition) {
                        Section("Floating") {
                            Label("Top Left", systemImage: "inset.filled.topleft.rectangle")
                                .tag(PreviewPosition.topLeft)
                            Label("Top Right", systemImage: "inset.filled.topright.rectangle")
                                .tag(PreviewPosition.topRight)
                            Label("Bottom Left", systemImage: "inset.filled.bottomleft.rectangle")
                                .tag(PreviewPosition.bottomLeft)
                            Label("Bottom Right", systemImage: "inset.filled.bottomright.rectangle")
                                .tag(PreviewPosition.bottomRight)
                        }
                        Section("Docked") {
                            Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                                .tag(PreviewPosition.bottomDock)
                            Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                                .tag(PreviewPosition.topDock)
                        }
                    } label: {
                        Label("Preview Position", systemImage: "pointer.arrow.and.square.on.square.dashed")
                    }

                    Picker(selection: .constant(0)) {
                        Text("Always Visible")
                        Text("Auto-hide")
                        Text("Hidden")
                    } label: {
                        Label("Preview Visibility", systemImage: "eye")
                    }
                }
            }
        }
    }
}

// #if os(macOS)
// @MainActor
// func createNewDocumentWithSavePanel() {
//     let panel = NSSavePanel()
//     panel.canCreateDirectories = true
//     panel.allowedContentTypes = [.imageFlowDocument]
//     panel.isExtensionHidden = false

//     panel.begin { response in
//         guard response == .OK, let url = panel.url else { return }

//         let doc = FlowDocument()

//         do {
//             let snap = try doc.snapshot(contentType: .imageFlowDocument)
//             let fw = try doc.fileWrapper(snapshot: snap)
//             try fw.write(to: url, options: [.atomic], originalContentsURL: nil)

//             NSDocumentController.shared.openDocument(
//                 withContentsOf: url,
//                 display: true,
//                 completionHandler: { _, _, err in
//                     if let err { NSApp.presentError(err) }
//                 }
//             )
//         } catch {
//             NSApp.presentError(error)

//         }
//     }
// }
// #endif

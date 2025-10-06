//
//  ImageFlowApp.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

//import AppKit
import Logging
import SwiftUI
import UniformTypeIdentifiers

//import CommonUtils

//import enum Models.Action

public struct ImageFlowApp: App {

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: { FlowDocument() }) { configuration in
            MainView(document: configuration.document)
                .onAppear {
                    log("url: \(configuration.fileURL, default: "no URL!!")")
                    if let url = configuration.fileURL {
                        try! "Hello!".write(to: url.appending(path: "Hello.txt"), atomically: true, encoding: .utf8)
                    }
                }
        }
        .commands {

            #if os(macOS)
            CommandGroup(replacing: .newItem) {
                Button("New...") {
                    createNewDocumentWithSavePanel()
                }
                .keyboardShortcut("n")
            }
            #endif
        }
        #if os(macOS)
        .defaultWindowPlacement { root, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(RunConfiguration.showWelcomeWindow ? .suppressed : .automatic)
        #endif

        #if os(iOS)
        DocumentGroupLaunchScene {

        }
        #endif

        WelcomeWindow("Image Flow")
            .defaultLaunchBehavior(RunConfiguration.showWelcomeWindow ? .presented : .suppressed)
    }
}

#if os(macOS)
@MainActor
func createNewDocumentWithSavePanel() {
    let panel = NSSavePanel()
    panel.canCreateDirectories = true
    panel.allowedContentTypes = [.imageFlowDocument]
    panel.isExtensionHidden = false

    panel.begin { response in
        guard response == .OK, let url = panel.url else { return }

        let doc = FlowDocument()

        do {
            let snap = try doc.snapshot(contentType: .imageFlowDocument)
            let fw = try doc.fileWrapper(snapshot: snap)
            try fw.write(to: url, options: [.atomic], originalContentsURL: nil)

            NSDocumentController.shared.openDocument(
                withContentsOf: url,
                display: true,
                completionHandler: { _, _, err in
                    if let err { NSApp.presentError(err) }
                }
            )
        } catch {
            NSApp.presentError(error)

        }
    }
}
#endif

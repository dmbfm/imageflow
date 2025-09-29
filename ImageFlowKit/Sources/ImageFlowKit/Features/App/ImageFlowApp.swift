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
            //            DocumentView(configuration.document)
        }
        #if os(macOS)
        .defaultWindowPlacement { root, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(.suppressed)
        #endif

        //        WelcomeWindow("Image Flow")
        //            .defaultLaunchBehavior(.presented)
    }
}

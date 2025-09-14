//
//  AppMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

#if canImport(AppKit)

import AppKit
import SwiftUI
import Logging
import CommonUtils

@MainActor
public struct ImageFlowApp {
    public static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        log("", level: .trace)
        NSApp.setupMainMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        log("", level: .trace)
    }
}

#endif

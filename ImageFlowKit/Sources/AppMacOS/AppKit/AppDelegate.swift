#if os(macOS)
import AppKit
import Helpers
import SharedModels
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    var welcomeWindowController: WelcomeWindowController? = nil
    var previewMenuDelegate: ViewMenuDelegate = .init()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info("applicationDidFinishLaunching")

        if let menu = NSApp.mainMenu?.item(withTitle: "View")?.submenu {
            menu.delegate = self.previewMenuDelegate
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        logger.info("applicationWillTerminate")
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        logger.info("applicationShouldTerminate")
        return .terminateNow
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        self.openWelcomeWindow()
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif

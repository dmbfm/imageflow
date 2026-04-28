import AppKit
import Helpers
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    var welcomeWindowController: WelcomeWindowController? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info("applicationDidFinishLaunching")
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

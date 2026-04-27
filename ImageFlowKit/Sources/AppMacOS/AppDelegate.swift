import AppKit
import Helpers
import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    var welcomeWindowController: WelcomeWindowController? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("ok!!!")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        print("applicationShouldOpenUntitledFile")
        self.openWelcomeWindow()
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        print("applicationOpenUntitledFile")
        return true
    }

    // MARK: - Welcome Window

}

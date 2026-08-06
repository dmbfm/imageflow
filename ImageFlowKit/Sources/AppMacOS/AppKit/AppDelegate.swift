#if os(macOS)
import AppKit
import Helpers
import SharedModels
import SwiftUI
import SettingsFeature
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    var welcomeWindowController: WelcomeWindowController? = nil
    var viewMenuDelegate: ViewMenuDelegate = .init()
    var cancellables: Set<AnyCancellable> = []

    @objc func openSettingsWindow(_ sender: Any?) {
        SettingsFeatureState.shared.openSettingsWindow()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info("applicationDidFinishLaunching")

        if let menu = NSApp.mainMenu(submenuWithTitle: "View") {
            menu.delegate = self.viewMenuDelegate
        }

        SettingsStore.shared.$appearance.sink { value in
            let app = NSApplication.shared
            switch value {
                case .dark: app.appearance = .init(named: .darkAqua)
                case .light: app.appearance = .init(named: .aqua)
                case .system: app.appearance = nil
            }
        }.store(in: &self.cancellables)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        logger.info("applicationWillTerminate")

        logger.info("Cleaning-up...")

        let fm = FileManager.default
        let url = fm.imageFlowTemporaryAssetsDirectory

        do {
            if fm.fileExists(atPath: url.path(), isDirectory: nil) {
                try fm.removeItem(at: url)
            }
        } catch {
            logger.error("Failed to remove temoporary assets directory!!")
        }

        logger.info("Cleaning-up... done!")
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

extension NSApplication {
    func mainMenu(submenuWithTitle title: String) -> NSMenu? {
        self.mainMenu?.item(withTitle: title)?.submenu
    }

    var mainViewController: MainViewController? {
        self.keyWindow?.contentViewController as? MainViewController
    }
}

#endif

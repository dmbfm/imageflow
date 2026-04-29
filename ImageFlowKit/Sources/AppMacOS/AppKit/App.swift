#if os(macOS)
import AppKit
import OSLog
import Helpers

let logger = Logger(subsystem: "com.dmbfm.imageflow.app-macos", category: "imageflow")

public struct EntryPoint {
    @MainActor
    public static func main() {
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}
#endif

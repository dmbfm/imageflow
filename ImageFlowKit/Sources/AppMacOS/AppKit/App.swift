#if os(macOS)
import AppKit
import OSLog
import Helpers

let logger = Logger(subsystem: "com.dmbfm.imageflow.app-macos", category: "imageflow")

@MainActor
class IsTrialVar: @unchecked Sendable {
    public var value: Bool = false
}

@MainActor
let trialVar: IsTrialVar = .init()

public struct EntryPoint {

    @MainActor
    public static func run(trialBuild: Bool = false) {
        trialVar.value = trialBuild
        let delegate = AppDelegate()
        NSApplication.shared.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}
#endif

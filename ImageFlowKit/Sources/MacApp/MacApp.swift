import AppKit
import SwiftUI

@MainActor
public struct ImageFlowApp: App {

	@NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
	
	public init() {}
	public var body: some Scene {}
    // public static func main() {
    //     let delegate = AppDelegate()
    //     NSApplication.shared.delegate = delegate
    //     _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    // }
}

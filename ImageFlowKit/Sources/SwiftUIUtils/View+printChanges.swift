import SwiftUI

fileprivate let env = ProcessInfo.processInfo.environment

fileprivate let enabled = {
    env["SWIFTUI_PRINT_CHANGES"] != nil
}()

extension View {
    public static func printChanges() {
        #if DEBUG
        if enabled {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSSS"
            print("[printChanges] " + formatter.string(from: date), terminator: " - ")
            Self._printChanges()
        }
        #endif
    }
}

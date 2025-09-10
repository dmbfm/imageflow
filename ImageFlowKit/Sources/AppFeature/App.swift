import SwiftUI

public struct ImageFlowApp: App {

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: ImageFlowDocument.sample) { configuration in
            MainView(document: configuration.$document)
            #if os(macOS)

            #endif
        }

        #if os(iOS)
        DocumentGroupLaunchScene {}
        #endif
    }
}

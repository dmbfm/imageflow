import SwiftUI

public struct ImageFlowApp: App {

    public init() {}

    public var body: some Scene {
        WindowGroup {
            VStack {
                Text("Hello!")
                    .padding(100)
                    .background(.teal.gradient.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(radius: 8)
            }
        }
    }
}

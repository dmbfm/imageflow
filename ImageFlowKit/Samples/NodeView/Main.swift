import AppKit
import SwiftUI


struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .frame(width: 800, height: 800)
        }
    }
}

@main
struct Application: App {
    init() {
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    var body: some Scene {
        Window("Preview", id: "preview") {
            ContentView()
                .frame(width: 800, height: 800)
        }
    }
}

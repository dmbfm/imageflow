#if os(macOS)

import SwiftUI
import AppKit
import Metal
import CoreGraphicsEx
import CoreImage
import CIImageView

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
            ScrollContentView()
        }
    }
}

struct ContentView: View {
    @State var image: CIImage? = nil

    var body: some View {
        ZStack {
            Color.teal
            CIImageView(image: self.image)
                .placement(.fit)
        }
        .onAppear {
            let nsImage = Bundle.module.image(forResource: "image.png")!
            self.image = CIImage(data: nsImage.tiffRepresentation!)!
        }
    }
}

#endif

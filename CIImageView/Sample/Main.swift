import CIImageView
import SwiftUI

struct CIImageScrollViewRepresentable: NSViewRepresentable {
    let image: CIImage?

    func makeNSView(context: Context) -> CIImageScrollNSView {
        let view = CIImageScrollNSView(frame: .zero)
        view.image = image
        view.imageView.onMouseOver = { info in
            print("\(info.debugDescription)")
        }
        return view
    }

    func updateNSView(_ view: CIImageScrollNSView, context: Context) {
        view.image = image
    }
}

struct CIImageViewRepresentable: NSViewRepresentable {
    let image: CIImage?
    func makeNSView(context: Context) -> CIImageNSView {
        let view = CIImageNSView(frame: .zero)
        view.image = self.image
        view.alignment = .center
        view.resizeMode = .fill
        view.onMouseOver = { info in
            print(info.debugDescription)
        }
        return view
    }

    func updateNSView(_ view: CIImageNSView, context: Context) {
        view.image = self.image
    }
}

struct ContentView: View {
    @State var image: CIImage? = nil
    @State var pixelInfo: CIImageNSView.PixelInfo? = nil
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.purple

            // CIImageScrollViewRepresentable(image: self.image)
            CIImageViewRepresentable(image: self.image)
            // CIImageView(image: self.image, resizeMode: .none, alignment: .center, pixelInfo: self.$pixelInfo)

            if let p = self.pixelInfo {
                Text("\(p.x), \(p.y): [\(p.color.r), \(p.color.g), \(p.color.b), \(p.color.a)]")
            }
        }
        .onAppear {
            if image == nil {
                self.image = CIImage(contentsOf: .init(filePath: "./img.png"))
            }
        }
    }
}

struct CIIImageViewSample: View {

    @State var image: CIImage? = nil
    @State var pixelInfo: CIImageNSView.PixelInfo? = nil
    @State var alignment: CIImageNSView.Alignment = .center
    @State var resizeMode: CIImageNSView.ResizeMode = .none
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.purple

            VStack {

                CIImageView(
                    image: self.image,
                    resizeMode: self.resizeMode,
                    alignment: self.alignment,
                    pixelInfo: self.$pixelInfo
                )

                VStack {

                    if let p = self.pixelInfo {
                        Text("\(p.x), \(p.y): [\(p.color.r), \(p.color.g), \(p.color.b), \(p.color.a)]")
                    } else {
                        Text("[mouse outside of image bounds]")
                    }

                    HStack {
                        Picker("Alignment", selection: self.$alignment) {
                            ForEach(CIImageNSView.Alignment.allCases, id: \.self) { alignment in
                                Text("\(alignment)").tag(alignment)
                            }
                        }

                        Picker("Resize Mode", selection: self.$resizeMode) {
                            ForEach(CIImageNSView.ResizeMode.allCases, id: \.self) { mode in
                                Text("\(mode)").tag(mode)
                            }
                        }
                    }
                }
            }

        }
        .onAppear {
            if image == nil {
                self.image = CIImage(contentsOf: .init(filePath: "./img.png"))
            }
        }
    }
}

struct CIIImageScrollViewSample: View {

    @State var image: CIImage? = nil
    @State var pixelInfo: CIImageNSView.PixelInfo? = nil
    @State var zoom: CGFloat = 1.0
    @State var ref: CIImageScrollView.Coordinator? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.purple

            VStack {

                CIImageScrollView(
                    image: self.image,
                    zoom: self.$zoom,
                    pixelInfo: self.$pixelInfo
                ) { ref in self.ref = ref }

                VStack {

                    if let p = self.pixelInfo {
                        Text("\(p.x), \(p.y): [\(p.color.r), \(p.color.g), \(p.color.b), \(p.color.a)]")
                    } else {
                        Text("[mouse outside of image bounds]")
                    }

                    HStack {
                        Button("Zoom In") { self.ref?.dispatch(.zoom(2.0)) }
                        Button("Zoom Out") { self.ref?.dispatch(.zoom(0.5)) }
                        Button("Fit") { self.ref?.dispatch(.fit(animate: true)) }
                        Button("Actual Size") { self.ref?.dispatch(.actualSize) }
                    }

                    Text("zoom: \(self.zoom)")
                }
            }

        }
        .onAppear {
            if image == nil {
                self.image = CIImage(contentsOf: .init(filePath: "./img.png"))
            }
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
            // CIIImageViewSample()
            CIIImageScrollViewSample()
        }
    }
}

import AppKit
import AppKitUtils
import CanvasFeature
import CanvasView
import Logging
import SwiftUI
import UniformTypeIdentifiers

// @objc(FlowDocument)
// class FlowDocument: NSDocument {
//     override func makeWindowControllers() {

//         let window = NSWindow(
//             contentRect: .init(origin: .zero, size: .init(width: 800, height: 600)),
//             styleMask: [.closable, .resizable, .miniaturizable, .titled],
//             backing: .buffered,
//             defer: false
//         )
//         window.contentView = NSHostingView(rootView: ContentView())
//         window.setFrameAutosaveName("imageflow-main-window")

//         // Create and add the toolbar
//         // let toolbar = NSToolbar(identifier: "ImageFlowToolbar")
//         // toolbar.delegate = viewController
//         // toolbar.allowsUserCustomization = false
//         // window.toolbar = toolbar

//         // Apply the window style
//         WindowStyle
//             .compact
//             .with(\.fullSizeContentView, true)
//             .apply(window)

//         let windowController = NSWindowController(window: window)
//         windowController.windowFrameAutosaveName = "imageflow-main-window"
//         self.addWindowController(windowController)

//         ////

//         // let doc = FlowDoc()
//         // let asset = AssetManager(source: doc)
//     }

// }

// struct ContentView: View {
//     var body: some View {
//         NavigationSplitView {
//             List {}
//         } detail: {
//             ZStack {
//                 Color.teal
//                 Text("Hello!")
//             }
//         }
//     }
// }

struct FlowDoc: FileDocument, Codable {

    var canvas: CanvasFeatureState = .init()

    static var readableContentTypes: [UTType] {
        [.imageFlowDocument]
    }

    init(configuration: ReadConfiguration) throws {
        log("loading...")
        guard let data = configuration.file.regularFileContents else {
            return
        }

        self.canvas = try JSONDecoder().decode(CanvasFeatureState.self, from: data)
    }

    init() {}

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        log("saving...")
        let data = try JSONEncoder().encode(self.canvas)
        let result = FileWrapper(regularFileWithContents: data)
        log("done!")
        return result
    }
}

// extension FlowDoc: AssetImageSource {
//     func get(image id: UUID) -> CGImage? {
//         self.assets[id]
//     }
// }

// protocol AssetImageSource {
//     func get(image id: UUID) -> CGImage?
// }

// actor AssetManager {
//     init(source: any AssetImageSource) {
//         self.source = source
//     }

//     var source: (AssetImageSource)
// }

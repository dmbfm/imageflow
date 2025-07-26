import AppKit
import AppKitUtils
import CanvasFeature
import CanvasView
import Logging
import SwiftUI
import UniformTypeIdentifiers

@objc(FlowDocument)
class FlowDocument: NSDocument {
    override func makeWindowControllers() {

        let window = NSWindow(
            contentRect: .init(origin: .zero, size: .init(width: 800, height: 600)),
            styleMask: [.closable, .resizable, .miniaturizable, .titled],
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: ContentView())
        window.setFrameAutosaveName("imageflow-main-window")

        // Create and add the toolbar
        // let toolbar = NSToolbar(identifier: "ImageFlowToolbar")
        // toolbar.delegate = viewController
        // toolbar.allowsUserCustomization = false
        // window.toolbar = toolbar

        // Apply the window style
        WindowStyle
            .compact
            .with(\.fullSizeContentView, true)
            .apply(window)

        let windowController = NSWindowController(window: window)
        windowController.windowFrameAutosaveName = "imageflow-main-window"
        self.addWindowController(windowController)

        //// 

        let doc = FlowDoc()
        let asset = AssetManager(source: doc)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {}
        } detail: {
            ZStack {
                Color.teal
                Text("Hello!")
            }
        }
    }
}

struct CanvasState {
    var viewport: CanvasViewport = .init()
    var positions: [(UUID, CGPoint)] = []
}

@Observable
final class FlowDoc: ReferenceFileDocument {

    var canvas: CanvasState
    var assets: [UUID: CGImage]

    func snapshot(contentType: UTType) throws -> Snapshot {
        .init()
    }

    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        .init()
    }

    struct Snapshot {}

    static var readableContentTypes: [UTType] {
        [.init(exportedAs: "com.dmbfm.imageFlowDocument")]
    }

    init(configuration: ReadConfiguration) throws {

    }

    init() {}
}

extension FlowDoc: AssetImageSource {
    func get(image id: UUID) -> CGImage? {
        self.assets[id]
    }
}

protocol AssetImageSource {
    func get(image id: UUID) -> CGImage?
}

actor AssetManager {
    init(source: any AssetImageSource) {
        self.source = source
    }

    var source: (AssetImageSource)
}

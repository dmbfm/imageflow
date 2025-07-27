import AppKit
import CanvasFeature
import NodeDataStore
import Logging
import SwiftUI

@MainActor
public struct ImageFlowApp: App {

    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: FlowDoc()) { configuration in
            ContentView(doc: configuration.$document)
        }
    }

    // public static func main() {
    //     let delegate = AppDelegate()
    //     NSApplication.shared.delegate = delegate
    //     _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    // }
}

struct ContentView: View {
    @Binding var doc: FlowDoc
    @State var nodeDataStore = NodeDataStore()
    // @State var canvas = CanvasFeatureState()

    var body: some View {
        NavigationSplitView {
            List {
                Text("\(doc.canvas.viewport.origin.x)")
                Text("\(doc.canvas.viewport.origin.y)")
            }
        } detail: {
            CanvasFeatureView(self.$doc.canvas, nodeDataStore: self.nodeDataStore)
        }
        .onChange(of: self.doc.canvas) {
            log("canvas: \(self.doc.canvas)")
        }
    }
}

import AppKit
import CanvasFeature
import Logging
import NodeDataStore
import SwiftUI

@MainActor
public struct ImageFlowApp: App {

    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: FlowDoc.sample) { configuration in
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
    @State var canvasState = CanvasFeature.State()
    // @State var canvas = CanvasFeatureState()

    var body: some View {
        NavigationSplitView {
            List {
                Text("\(self.canvasState.viewport.origin.x)")
                Text("\(self.canvasState.viewport.origin.y)")
            }
        } detail: {
            CanvasFeatureView(self.$canvasState, self.$doc.canvasStore, self.$doc.nodeDataStore)
        }
        .onChange(of: self.doc.canvasStore) {
            log("canvas: \(self.doc.canvasStore)")
        }
    }
}

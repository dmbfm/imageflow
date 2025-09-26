#if canImport(AppKit)

import CanvasFeature
import NodeDataStore
import NodeSelectionStore
import CommonUtils
import Logging
import Models
import SwiftUI
import SidebarFeature

struct MainViewMac: View {

    let canvas: CanvasFeatureState
    let nodeDataStore: NodeDataStore
    let nodeSelectionStore: NodeSelectionStore

    // @ObservedObject var document: ImageFlowDocument
    @Binding var canvasCenter: Box<CGPoint>
    @Environment(\.dismissWindow) var dismissWindow
    @FocusState var focus: Focus?
    @Environment(\.undoManager) var undoManager

    var onDeleteCommandHandler: (() -> ())? {
        if self.nodeSelectionStore.selection.isEmpty {
            nil
        } else {
            {
                self.deleteNodes(self.nodeSelectionStore.selection)
                // self.deleteNodes(self.nodeDataStore.selection)
                // self.flow.deleteNodes(self.flow.selection, undoManager: self.undoManager, undoTitle: "Delete Node")
                // log("deleting nodes: \(self.flow.selection)", level: .debug)
            }
        }
    }

    func deleteNodes(_ nodes: Set<UUID>) {
        fatalError("TODO: Not Implemented")
    }

    func onAppear() {
        // self.dispatcher.listen { self.dispatch($0) }
        self.dismissWindow(id: WindowID.welcome.rawValue)
    }

    var body: some View {
        self.mainView
            .onAppear(perform: self.onAppear)
            .focusable()
            .focused(self.$focus, equals: .global)
            .onDeleteCommand(perform: self.onDeleteCommandHandler)
            .onChange(of: self.focus, { log("focus: \(String(describing: self.focus))", level: .debug) })
    }

    @ViewBuilder
    var mainView: some View {
        NavigationSplitView {
            SidebarFeatureView(self.$focus)
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
        } detail: {
            self.detailView
        }
    }

    @ViewBuilder
    var detailView: some View {
        ZStack {
            CanvasFeatureView(self.canvas, self.nodeDataStore, self.nodeSelectionStore, self.$focus)
                .onGeometryChange(for: CGPoint.self) { proxy in
                    proxy.frame(in: .local).center
                } action: { newValue in
                    self.canvasCenter.value = newValue
                }
        }
    }
}

#endif

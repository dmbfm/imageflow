#if canImport(AppKit)

import SwiftUI

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
            }
        }
    }

    func deleteNodes(_ nodes: Set<UUID>) {
        fatalError("TODO: Not Implemented")
    }

    func onAppear() {
        self.dismissWindow(id: WindowID.welcome.rawValue)
    }

    func onChangeOfFocus() {
        log("focus: \(String(describing: self.focus))", level: .debug)
    }

    var body: some View {
        self.mainView
            .onAppear(perform: self.onAppear)
            .focusable()
            .focused(self.$focus, equals: .global)
            .onDeleteCommand(perform: self.onDeleteCommandHandler)
            .onChange(of: self.focus, { self.onChangeOfFocus() })
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

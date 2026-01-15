import Backend
import Helpers
import Logging
import SwiftUI
import Values

public struct CanvasFeatureView: View {

    // MARK: - State

    @ObservableState private var vm: CanvasFeatureViewModel

    @Environment(\.undoManager) private var undoManager: UndoManager?

    typealias Delegate = NodeInputBlockView.Delegate

    // MARK: - Initializers

    init(
        _ state: CanvasFeatureState,
        _ flow: Flow,
        _ assetStore: AssetStore,
        _ focus: FocusState<Focus?>.Binding,
        _ delegate: Delegate?
    ) {
        self._vm = .init(
            wrappedValue: .init(
                state: state,
                flow: flow,
                assetStore: assetStore,
                focus: focus,
                delegate: delegate
            )
        )
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .topLeading) {
            CanvasView(
                self.$vm.state.viewport,
                self.vm.nodePositions,
                self.vm.edgeLayers,
                self.vm.canvasPlatformViewRefBinding,
                self.vm.viewForNode,
                self.vm.onCanvasEvent,
            )
            .ignoresSafeArea()
            .dropDestination(for: NodeKindDragItem.self, action: self.vm.dropDestinationHandler(_:_:))
            .onChange(of: self.vm.flow.edges, initial: true) { self.vm.updateEdges() }
            .onChange(of: self.vm.nodePositions, initial: true) { self.vm.updateEdges() }
            .onChange(of: self.vm.flow.nodes, initial: true) { self.vm.updateNodeData() }
            .onChange(of: self.vm.flow.selection, initial: true) { self.vm.updateSelection() }
            .onChange(
                of: self.undoManager,
                initial: true,
                { self.vm.undoManager = self.undoManager }
            )
            .onChange(of: self.vm.flow.partialEdge) { self.vm.updateEdges() }

            CanvasImagePreviewView(flow: self.vm.flow, assetStore: self.vm.assetStore) { _ in }
                #if os(iOS)
            .safeAreaPadding(.top, 60)
                #endif
        }
    }
}

fileprivate struct CanvasImagePreviewView: View {
    let flow: Flow
    let assetStore: AssetStore
    let launchPreviewWindow: (AssetIdentifier) -> ()
    var body: some View {
        PreviewFeatureView(self.flow, self.assetStore)
    }
}

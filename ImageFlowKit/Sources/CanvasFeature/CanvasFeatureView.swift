import Backend
import CanvasView
import Helpers
import Logging
import NodePaletteFeature
import NodeView
import PreviewFeature
import SharedModels
import SwiftUI
import Values

import class SharedModels.Flow

public struct CanvasFeatureView: View {

    // MARK: - State

    @Binding var action: Action?

    @ObservableState private var vm: CanvasFeatureViewModel

    @Environment(\.undoManager) private var undoManager: UndoManager?

    public typealias Delegate = NodeViewDelegate

    public enum Action {
        case showNodeSearchPopover
    }

    // MARK: - Initializers

    public init(
        _ state: CanvasFeatureState,
        _ flow: Flow,
        _ assetStore: any AssetStoreService,
        _ focus: FocusState<Focus?>.Binding,
        _ delegate: Delegate?,
        action: Binding<Action?>,
    ) {
        self._vm = .init(
            wrappedValue: .init(
                state: state,
                flow: flow,
                assetStore: assetStore,
                focus: focus,
                delegate: delegate,
            )
        )
        self._action = action
    }

    func onAction() {
        if let action = self.action {
            switch action {
            case .showNodeSearchPopover:
                self.vm.nodeSearchPopoverIsPresented = true
                break
            }
            self.action = nil
        }
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
                contextMenuProvider: self.vm,
                self.vm.onCanvasEvent,
            )
            .ignoresSafeArea()
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
            .onChange(of: self.action) { self.onAction() }

            #if os(macOS)
            VStack {
                Color.red.opacity(0)
            }
            .popover(
                isPresented: self.$vm.nodeSearchPopoverIsPresented,
                arrowEdge: .bottom,
                content: { self.nodeSearchPopoverContent }
            )
            .ignoresSafeArea(.all)
            .frame(width: 10, height: 10)
            .position(self.vm.nodeSearchPopoverPosition)
            .ignoresSafeArea(.all)
            #endif

            CanvasImagePreviewView(flow: self.vm.flow, assetStore: self.vm.assetStore) { _ in }
                #if os(iOS)
            .safeAreaPadding(.top, 60)
                #endif

            DropOverlay(vm: self.vm)
        }
    }

    struct DropOverlay: View, @MainActor Equatable {
        static func == (lhs: CanvasFeatureView.DropOverlay, rhs: CanvasFeatureView.DropOverlay) -> Bool {
            return true
        }

        let vm: CanvasFeatureViewModel
        var body: some View {
            Color.clear
                .dropDestination(for: NodeKindDragItem.self, action: self.vm.dropDestinationHandler(_:_:))
        }

    }

    #if os(macOS)
    var nodeSearchPopoverContent: some View {
        NodePaletteSearchPopoverView(
            self.vm.trackedMousePosition,
            focus: self.vm.focus,
            onPickItem: self.vm.nodeSearchPopover(didPickItem:at:),
            dismiss: self.vm.nodeSearchPopoverDismiss,
        )
    }
    #endif
}

fileprivate struct CanvasImagePreviewView: View {
    let flow: Flow
    let assetStore: any AssetStoreService
    let launchPreviewWindow: (AssetIdentifier) -> ()
    var body: some View {
        PreviewFeatureView(self.flow, self.assetStore)
    }
}

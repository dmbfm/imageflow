import Backend
import CanvasView
import Helpers
import Logging
import NodePaletteFeature
import NodeView
import PreviewFeature
import SharedMocking
import SharedModels
import SwiftUI
import Values

import class SharedModels.Flow

public struct CanvasFeatureView: View {

    // MARK: - State

    @ObservableState private var vm: CanvasFeatureViewModel

    @Environment(\.undoManager) private var undoManager: UndoManager?

    // MARK: - Initializers

    public init(
        _ state: CanvasFeatureState,
        _ flow: Flow,
        _ assetStore: any AssetStoreService,
        _ focus: FocusState<Focus?>.Binding,
        coordinator: GlobalCoordinator
    ) {
        self._vm = .init(
            wrappedValue: .init(
                state: state,
                flow: flow,
                assetStore: assetStore,
                focus: focus,
                delegate: coordinator.implementation as? NodeViewDelegate,
                coordinator: coordinator,
            )
        )
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .topLeading) {
            CanvasView(
                viewport: self.$vm.state.viewport,
                nodePositions: self.vm.nodePositions,
                edges: self.vm.edgeLayers,
                canvasPlatformViewRef: self.vm.canvasPlatformViewRefBinding,
                viewForNode: self.vm.viewForNode,
                contextMenuProvider: self.vm,
                delegate: self.vm,
                interactionMode: self.vm.interactionMode,
                onEvent: self.vm.onCanvasEvent,
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

            #if os(macOS)
            VStack {
                Color.red.opacity(0)
            }
            .popover(
                isPresented: self.$vm.nodeSearchPopoverState.isPresented,
                arrowEdge: .bottom,
                content: { self.nodeSearchPopoverContent }
            )
            .ignoresSafeArea(.all)
            .frame(width: 10, height: 10)
            .position(self.vm.nodeSearchPopoverState.mousePosition ?? .zero)
            .ignoresSafeArea(.all)
            #endif

            CanvasImagePreviewView(
                flow: self.vm.flow,
                assetStore: self.vm.assetStore,
                coordinator: self.vm.coordinator
            )
            #if os(iOS)
            .safeAreaPadding(.top, 60)
            #endif
            .opacity(self.vm.hidePreviews ? 0 : 1)
            .animation(.smooth(duration: 0.2), value: self.vm.hidePreviews)

            #if os(iOS)
            self.interactiveSelectionToolbarView
            #endif

            DropOverlay(vm: self.vm)
        }
        .activeViewObject(self.vm)
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

    #if os(iOS)
    var interactiveSelectionToolbarView: some View {
        ZStack(alignment: .bottom) {
            Color.clear
            InteractiveSelectionToolbarView(
                visible: self.vm.interactiveSelectionToolbarIsPresented,
                onAction: self.vm.interactiveSelectionToolbarAction(_:)
            )
            .padding(.bottom, 60)
        }
    }
    #endif

    #if os(macOS)
    var nodeSearchPopoverContent: some View {
        NodePaletteSearchPopoverView(
            self.vm.nodeSearchPopoverState.mousePosition,
            typedPortLocation: self.vm.nodeSearchPopoverState.typedPortLocation,
            focus: self.vm.focus,
            onPickItem: self.vm.nodeSearchPopover(didPickItem:at:),
            dismiss: self.vm.nodeSearchPopoverDismiss,
        )
    }
    #endif
}

private struct CanvasImagePreviewView: View {
    let flow: Flow
    let assetStore: any AssetStoreService
    let coordinator: GlobalCoordinator

    var body: some View {
        PreviewFeatureView(self.flow, self.assetStore, coordinator: self.coordinator)
    }
}

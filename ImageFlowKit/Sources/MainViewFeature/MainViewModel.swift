import AssetManager
import BackendService
import CanvasFeature
import FlowDocument
import Helpers
import Logging
import SharedModels
import SwiftUI

@Observable
@MainActor
public class AppMenuCoordinator {

    public var action: Action? = nil {
        didSet {
            if let action = self.action {
                self.dispatch?(action)
                self.action = nil
            }
        }
    }

    public var nodeSelectionCount: Int = 0

    public var dispatch: ((Action) -> ())? = nil

    public enum Action {
        case deleteSelectedNodes
        case duplidateSelectedNodes
    }

    public init(action: Action? = nil, dispatch: ((Action) -> Void)? = nil) {
        self.action = action
        self.nodeSelectionCount = nodeSelectionCount
        self.dispatch = dispatch
    }
}

@Observable
@MainActor
final class MainViewModel {
    var document: FlowDocument
    var documentInfo: DocumentInfo
    var undoManager: UndoManager?

    let flow: Flow
    let canvas: CanvasFeatureState
    let assetStore: AssetStore
    let backendService: BackendService
    let appMenuCoordinator: AppMenuCoordinator

    init(document: FlowDocument, documentInfo: DocumentInfo) {
        self.document = document
        self.documentInfo = documentInfo

        let flow = Flow()
        let canvas = CanvasFeatureState()
        let assetStore = AssetStore()

        self.canvas = canvas
        self.assetStore = assetStore
        self.assetStore.setDocumentInfo(documentInfo)
        self.flow = flow
        self.backendService = .init(flow, assetStore.assetManager)
        self.appMenuCoordinator = AppMenuCoordinator()

        self.flow.delegate = self
        self.assetStore.delegate = self

        self.appMenuCoordinator.dispatch = { [weak self] action in
            switch action {
            case .deleteSelectedNodes:
                self?.flow.deleteSelectedNodesAction(undoManager: self?.undoManager)
            case .duplidateSelectedNodes:
                self?.flow.duplidateSelectedNodesAction(undoManager: self?.undoManager)
            }
        }
    }

    func onAppear() {
        self.document.flow.withLock { data in
            self.flow.restore(data)
        }
        self.document.canvas.withLock { canvas in
            self.canvas.restore(canvas)
        }

        self.document.assetStore.withLock { assetStore in
            self.assetStore.restore(assetStore)
        }

        self.backendService.start()
    }

    func documentInfoDidChange(_ documentInfo: DocumentInfo) {
        self.documentInfo = documentInfo
        self.assetStore.setDocumentInfo(self.documentInfo)
    }
}

extension MainViewModel: FlowDelegate {
    func flow(nodesDidChange nodes: [UUID: SharedModels.FlowNode]) {
        self.document.flow.withLockIfAvailable {
            $0.nodes = nodes
        }
    }

    func flow(edgesDidChange edges: Set<SharedModels.Edge>) {
        document.flow.withLockIfAvailable {
            $0.edges = edges
        }
    }

    func flow(nodePositionsDidChange nodePositions: [UUID: CGPoint]) {
        document.flow.withLockIfAvailable {
            $0.nodePositions = nodePositions
        }
    }

    func flow(selectionDidChange selection: Set<UUID>) {
        self.appMenuCoordinator.nodeSelectionCount = selection.count
    }

}

extension MainViewModel: AssetStoreServiceDelegate {
    func assetsStore(assetsDidChange assets: [UUID: SharedModels.Asset]) {
        self.document.assetStore.withLockIfAvailable {
            $0.assets = assets
        }
    }
}

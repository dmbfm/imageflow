import Helpers
import Logging
import SwiftUI

@Observable
@MainActor
class AppMenuCoordinator {

    var action: Action? = nil {
        didSet {
            if let action = self.action {
                self.dispatch?(action)
                self.action = nil
            }
        }
    }

    var nodeSelectionCount: Int = 0

    var dispatch: ((Action) -> ())? = nil

    enum Action {
        case deleteSelectedNodes
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
        self.backendService = .init(flow, assetStore)
        self.appMenuCoordinator = AppMenuCoordinator()

        // Observe for AssetStore changes (assets )
        self.assetStore.delegate = .init(assetsDidChange: { [weak document = self.document] assets in
            document?.assetStore.withLockIfAvailable {
                $0.assets = assets
            }
        })

        // Observe for Flow changes (nodes, edges, nodePositions)
        self.flow.delegate = .init(
            nodesDidChange: { [weak document = self.document] nodes in
                if let document {
                    document.flow.withLockIfAvailable {
                        $0.nodes = nodes
                    }
                }
            },
            edgesDidChange: { [weak document = self.document] edges in
                if let document {
                    document.flow.withLockIfAvailable {
                        $0.edges = edges
                    }
                }
            },
            nodePositionsDidChange: {
                [weak document = self.document] nodePositions in
                if let document {
                    document.flow.withLockIfAvailable {
                        $0.nodePositions = nodePositions
                    }
                }
            },
            selectionDidChange: {
                [weak coordinator = self.appMenuCoordinator] selection in
                coordinator?.nodeSelectionCount = selection.count
            }
        )

        // Observe for Canvas iewport changes:
        self.canvas.delegate = .init(viewportDidChange: { [weak document = self.document] viewport in
            document?.canvas.withLockIfAvailable {
                $0.viewport = viewport
            }
        })

        self.appMenuCoordinator.dispatch = { [weak self] action in
            switch action {
            case .deleteSelectedNodes:
                self?.flow.deleteSelectedNodesAction(undoManager: self?.undoManager)
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

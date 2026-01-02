import Logging
import SwiftUI

extension EnvironmentValues {
    @Entry var assetManager: AssetManager? = nil
}

struct MainView: View {

    let document: FlowDocument
    let documentInfo: DocumentInfo

    @State var flow: Flow
    @State var canvas: CanvasFeatureState
    @State var assetStore: AssetStore
    @State var backendService: BackendService? = nil

    @Environment(\.dismissWindow) var dismissWindow

    init(document: FlowDocument, documentInfo: DocumentInfo) {
        self.document = document
        self.documentInfo = documentInfo

        let flow = Flow()
        let canvas = CanvasFeatureState()
        let assetStore = AssetStore()

        self.canvas = canvas
        self.assetStore = assetStore
        self.flow = flow

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

            }
        )

        // Observe for Canvas iewport changes:
        self.canvas.delegate = .init(viewportDidChange: { [weak document = self.document] viewport in
            document?.canvas.withLockIfAvailable {
                $0.viewport = viewport
            }
        })
    }

    func onAppear() {
        #if os(macOS)
        self.dismissWindow(id: WindowID.welcome.rawValue)
        #endif

        self.document.flow.withLock { data in
            self.flow.restore(data)
        }
        self.document.canvas.withLock { canvas in
            self.canvas.restore(canvas)
        }

        self.document.assetStore.withLock { assetStore in
            self.assetStore.restore(assetStore)
        }

        if RunConfiguration.useSampleData {
            loadSampleData()
        }

        self.backendService = .init(self.flow, self.assetStore)
        self.backendService?.start()
    }

    func onChangeOfDocumentInfo() {
        self.assetStore.setDocumentInfo(self.documentInfo)
    }

    var body: some View {
        MainContentView(
            flow: self.flow,
            canvas: self.canvas,
            assetStore: self.assetStore
        )
        .onChange(of: self.documentInfo, initial: true) { self.onChangeOfDocumentInfo() }
        .onAppear(perform: self.onAppear)
    }
}

extension MainView {
    func loadSampleData() {
        let ids = (0...2).map { _ in UUID() }
        self.flow.addNode(.init(id: ids[0], kind: .valueNode(.float)), at: .init(x: 200, y: 200))
        self.flow.addNode(.init(id: ids[1], kind: .valueNode(.float)), at: .init(x: 200, y: 350))
        self.flow.addNode(.init(id: ids[2], kind: .addNode(.float)), at: .init(x: 500, y: 275))
        let e1 = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[2], port: .input(0)))!
        try! self.flow.canCreateEdge(e1).get()
        self.flow.newEdgeAction(e1)
        let e2 = Edge(.init(node: ids[1], port: .output(0)), .init(node: ids[2], port: .input(1)))!
        try! self.flow.canCreateEdge(e2).get()
        self.flow.newEdgeAction(e2)
    }
}

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

        Task { await self.observeImageAssets() }
        Task { await self.observeNodes() }
        Task { await self.observeNodePositions() }
        Task { await self.observeEdges() }
        Task { await self.observeViewport() }

        if RunConfiguration.useSampleData {
            loadSampleData()
        }

        self.backendService = .init(self.flow, self.assetStore)
        self.backendService?.start()
    }

    func observeImageAssets() async {
        let observation = Observations {
            self.assetStore.assets
        }

        for await assets in observation {
            self.document.assetStore.withLock {
                $0.assets = assets
            }
        }
    }

    func observeViewport() async {
        let observation = Observations {
            return self.canvas.viewport
        }

        for await viewport in observation {
            self.document.canvas.withLock {
                $0.viewport = viewport
            }
        }
    }

    func observeNodes() async {
        let observation = Observations {
            self.flow.nodes
        }

        for await nodes in observation {
            self.document.flow.withLock {
                $0.nodes = nodes
            }
        }
    }

    func observeNodePositions() async {
        let observation = Observations {
            self.flow.nodePositions
        }

        for await nodePositions in observation {
            self.document.flow.withLock {
                $0.nodePositions = nodePositions
            }
        }
    }

    func observeEdges() async {
        let observation = Observations {
            self.flow.edges
        }

        for await edges in observation {
            self.document.flow.withLock {
                $0.edges = edges
            }
        }
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

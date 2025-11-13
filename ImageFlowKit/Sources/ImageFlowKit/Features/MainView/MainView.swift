import Logging
import SwiftUI

extension EnvironmentValues {
    @Entry var assetManager: AssetManager? = nil
}

struct MainView: View {

    let document: FlowDocument
    let documentInfo: DocumentInfo

    @State var flow: Flow = .init()
    @State var canvas: CanvasFeatureState = .init()
    @State var assetStore: AssetStore = .init()

    @Environment(\.dismissWindow) var dismissWindow

    func onAppear() {

        log("documentInfo: \(documentInfo)")

        #if os(masOS)
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

        Task {
            await self.observeImageAssets()
            await self.observeNodes()
            await self.observeEdges()
            await self.observeViewport()
        }

        if RunConfiguration.useSampleData {
            loadSampleData()
        }
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
            self.canvas.viewport
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
        log("documentInfo: \(self.documentInfo)")
        self.assetStore.setDocumentInfo(self.documentInfo)
        Task {
            let info = await self.assetStore.assetManager.documentInfo
            log("assetManager.documenInfo: \(info, default: "nil")")
        }
    }

    var body: some View {
        MainContentView(flow: self.flow, canvas: self.canvas, assetStore: self.assetStore)
            .onChange(of: self.documentInfo, initial: true) { self.onChangeOfDocumentInfo() }
            .onAppear(perform: self.onAppear)
    }
}

extension MainView {
    func loadSampleData() {
        let ids = (0...2).map { _ in UUID() }
        self.flow.addNode(.init(id: ids[0], kind: .valueNode(.float), position: .init(x: 200, y: 200)))
        self.flow.addNode(.init(id: ids[1], kind: .valueNode(.float), position: .init(x: 200, y: 350)))
        self.flow.addNode(.init(id: ids[2], kind: .addNode(.float), position: .init(x: 500, y: 275)))
        let e1 = Edge(.init(node: ids[0], port: .output(0)), .init(node: ids[2], port: .input(0)))!
        try! self.flow.canCreateEdge(e1).get()
        self.flow.newEdgeAction(e1)
        let e2 = Edge(.init(node: ids[1], port: .output(0)), .init(node: ids[2], port: .input(1)))!
        try! self.flow.canCreateEdge(e2).get()
        self.flow.newEdgeAction(e2)
    }
}

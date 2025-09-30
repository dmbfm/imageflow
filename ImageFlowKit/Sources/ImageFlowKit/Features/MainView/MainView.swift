import SwiftUI
import Logging

struct MainView: View {

    let document: FlowDocument
    @State var flow: Flow = .init()
    @State var canvas: CanvasFeatureState = .init()

    func onAppear() {
        self.document.flow.withLock { data in
            self.flow.restore(data)
        }
        self.document.canvas.withLock { canvas in
            self.canvas.restore(canvas)
        }
        self.observeNodes()
        self.observeEdges()
        self.observeViewport()

        if RunConfiguration.useSampleData {
            loadSampleData()
        }
    }

    func observeViewport() {
        withObservationTracking(
            {
                _ = self.canvas.viewport
            },
            onChange: {
                Task { @MainActor in
                    self.document.canvas.withLock {
                        $0.viewport = self.canvas.viewport
                    }
                    self.observeViewport()
                }
            }
        )
    }

    func observeNodes() {
        withObservationTracking(
            {
                _ = self.flow.nodes
            },
            onChange: {
                Task { @MainActor in
                    self.update(\.nodes, \.nodes)
                    self.observeNodes()
                }
            }
        )
    }

    func observeEdges() {
        withObservationTracking(
            {
                _ = self.flow.edges
            },
            onChange: {
                Task { @MainActor in
                    self.update(\.edges, \.edges)
                    self.observeEdges()
                }
            }
        )
    }

    func update<T>(
        _ kpa: WritableKeyPath<Flow.StorableData, T>,
        _ kpb: WritableKeyPath<Flow, T>
    ) {
        document.flow.withLock { data in
            data[keyPath: kpa] = self.flow[keyPath: kpb]
        }
    }

    var body: some View {
        MainViewContentView(flow: self.flow, canvas: self.canvas)
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

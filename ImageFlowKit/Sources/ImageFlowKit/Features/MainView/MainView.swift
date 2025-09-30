import SwiftUI

struct MainView: View {

    let document: FlowDocument
    @State var flow: Flow = .init()
    @State var canvas: CanvasFeatureState = .init()

    func onAppear() {
        self.document.flow.withLock { data in
            // self.flow.restore(data)
            self.flow = .init(data)
        }
        self.document.canvas.withLock { canvas in
            // self.canvas.restore(canvas)
            self.canvas = .init(canvas)
        }
        self.observeNodes()
        self.observeEdges()
        self.observeViewport()
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
        document.flow.withLock { flow in
            flow[keyPath: kpa] = self.flow[keyPath: kpb]
        }
    }

    var body: some View {
        MainViewContentView(flow: self.flow, canvas: self.canvas)
            .onAppear(perform: self.onAppear)
    }
}

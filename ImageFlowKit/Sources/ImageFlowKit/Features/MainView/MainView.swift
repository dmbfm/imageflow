import SwiftUI

struct MainView: View {

    let document: FlowDocument
    @State var flow: Flow = .init()

    func onAppear() {
        self.document.data.withLock { data in
            self.flow = .init(data)
        }
        self.observeNodes()
        self.observeEdges()
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
        document.data.withLock { flow in
            flow[keyPath: kpa] = self.flow[keyPath: kpb]
        }
    }

    var body: some View {
        MainContentView()
            .onAppear(perform: self.onAppear)
    }
}

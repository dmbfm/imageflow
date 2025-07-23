import CanvasView
import Logging
import NodeDataStore
import NodeView
import SwiftUI

@Observable
@MainActor
public class CanvasFeatureState {
    public var viewport: CanvasViewport = .init()
    public var nodePositions: [NodePositionItem] = []

    public struct NodePositionItem: Sendable, Hashable, Identifiable {
        public var id: UUID
        public var position: CGPoint
    }

    public init(viewport: CanvasViewport = .init(), nodePositions: [NodePositionItem] = []) {
        self.viewport = viewport
        self.nodePositions = nodePositions
    }
}

extension CanvasFeatureState: Equatable {
    public static nonisolated func == (lhs: CanvasFeatureState, rhs: CanvasFeatureState) -> Bool {
        MainActor.assumeIsolated {
            lhs.viewport == rhs.viewport && lhs.nodePositions == rhs.nodePositions
        }
    }
}

public struct CanvasFeatureView: View {

    @Bindable var state: CanvasFeatureState
    let nodeDataStore: NodeDataStore

    public var body: some View {
        CanvasView(viewport: self.$state.viewport) {
            ForEach(self.state.nodePositions) { item in
                PinkNodeView()
                    .offset(item.position.cgSize)
            }
        }
    }
}

#Preview {
    @Previewable @State var state = CanvasFeatureState(nodePositions: [
        .init(id: .init(), position: .zero),
        .init(id: .init(), position: .init(x: 200, y: 200)),
    ])
    @Previewable @State var nodeDataStore = NodeDataStore()
    VStack {
        CanvasFeatureView(state: state, nodeDataStore: nodeDataStore)
    }
    .frame(width: 500, height: 500)
    .border(.gray.opacity(0.2))
    .padding()
}

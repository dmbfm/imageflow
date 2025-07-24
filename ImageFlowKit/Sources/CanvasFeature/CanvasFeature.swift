import CanvasView
import CommonUtils
import Logging
import Models
import NodeDataStore
import NodeView
import SwiftUI
import SwiftUIUtils

// MARK: - State

@Observable
@MainActor
public class CanvasFeatureState: PortPositionStorageProtocol {
    public var viewport: CanvasViewport = .init()
    public var nodePositionStore: NodePositionStore = .init()

    @ObservationIgnored
    var portPositions: [PortLocation:CGPoint] = [:]

    public init(viewport: CanvasViewport = .init(), nodePositionStore: NodePositionStore = .init()) {
        self.viewport = viewport
        self.nodePositionStore = nodePositionStore
    }

    public func positionBinding(_ id: UUID) -> Binding<CGPoint> {
        .init {
            self.nodePositionStore[id]
        } set: { newValue in
            self.nodePositionStore[id] = newValue
        }
    }

    public func updatePortPosition(_ location: PortLocation, _ position: CGPoint) {
        self.portPositions[location] = self.viewport.convert(position, from: .screen, to: .canvas)
    }
}

extension CanvasFeatureState: Equatable {
    public static nonisolated func == (lhs: CanvasFeatureState, rhs: CanvasFeatureState) -> Bool {
        MainActor.assumeIsolated {
            lhs.viewport == rhs.viewport && lhs.nodePositionStore == rhs.nodePositionStore
        }
    }
}

// MARK: - View

public struct CanvasFeatureView: View {

    @Bindable var state: CanvasFeatureState
    let nodeDataStore: NodeDataStore

    public var body: some View {
        CanvasView(viewport: self.$state.viewport) {
            ForEach(self.state.nodePositionStore.items) { item in
                NodeView(node: .constant(.init(kind: .addNode(.float))))
                    .offset(item.position.cgSize)
                    .dragNode(self.state.positionBinding(item.id))
            }
            .environment(\.portPositionStorage, self.state)

            ForEach(Array(self.nodeDataStore.edges)) { (edge: Models.Edge) in
                // EdgeView(edge: .init(start: edge.from, end: edge.to, color: .red))
            }
        }
    }
}

// MARK: - NodePositionStore

public struct NodePositionStore: Sendable, Hashable {
    public var items: [Item] = []

    public struct Item: Sendable, Hashable, Identifiable {
        public var id: UUID
        public var position: CGPoint

        public init(id: UUID, position: CGPoint) {
            self.id = id
            self.position = position
        }
    }

    public init(items: [NodePositionStore.Item] = []) {
        self.items = items
    }

    subscript(id: UUID) -> CGPoint {
        get {
            for item in self.items {
                if item.id == id {
                    return item.position
                }
            }

            fatalError("Invalid id: \(id)")
        }

        set {
            for index in self.items.indices {
                if self.items[index].id == id {
                    self.items[index].position = newValue
                    return
                }
            }

            fatalError("Invalid id: \(id)")
        }

    }
}

class PortPositionStorage: PortPositionStorageProtocol {
    var items: [PortLocation: CGPoint] = [:]
    func updatePortPosition(_ location: Models.PortLocation, _ position: CGPoint) {
        self.items[location] = position
        print(self.items)
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var state = CanvasFeatureState(
        nodePositionStore: .init(items: [
            .init(id: .init(), position: .zero),
            .init(id: .init(), position: .init(x: 250, y: 250)),
        ])
    )
    @Previewable @State var nodeDataStore = NodeDataStore()
    VStack {
        CanvasFeatureView(state: state, nodeDataStore: nodeDataStore)
    }
    .frame(width: 500, height: 500)
    .border(.gray.opacity(0.2))
    .padding()
}

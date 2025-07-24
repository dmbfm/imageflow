import CanvasView
import CommonUtils
import Design
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

    // @ObservationIgnored
    public var portPositions: [PortLocation: CGPoint] = [:]

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

    public func portPosition(_ location: PortLocation) -> CGPoint? {
        self.portPositions[location]
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
    var nodeDataStore: NodeDataStore

    public var body: some View {
        CanvasView(viewport: self.$state.viewport) {
            ForEach(Array(self.nodeDataStore.edges)) { (edge: Models.Edge) in
                if let start = self.state.portPositions[edge.from], let end = self.state.portPositions[edge.to] {
                    EdgeView(edge: .init(start: start, end: end, color: Colors.edgeWithSuccess.color))
                }
            }

            ForEach(self.state.nodePositionStore.items) { item in
                NodeView(
                    node: .init {
                        self.nodeDataStore.nodes[item.id]!
                    } set: { newValue in
                        self.nodeDataStore.nodes[item.id] = newValue
                    }
                )
                .offset(item.position.cgSize)
                .dragNode(self.state.positionBinding(item.id))
            }
            .environment(\.portPositionStorage, self.state)

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

// MARK: - Previews

fileprivate struct PreviewData {
    static let id1 = UUID()
    static let id2 = UUID()
}

#Preview {
    @Previewable @State var state = {
        let state = CanvasFeatureState(
            nodePositionStore: .init(items: [
                .init(id: PreviewData.id1, position: .zero),
                .init(id: PreviewData.id2, position: .init(x: 250, y: 250)),
            ])
        )
        return state
    }()
    @Previewable @State var nodeDataStore = {
        // let store = NodeDataStore(
        //     [
        //         PreviewData.id1: FlowNode(id: PreviewData.id1, kind: .addNode(.float)),
        //         PreviewData.id2: FlowNode(id: PreviewData.id2, kind: .addNode(.float)),
        //     ],
        //     edges: Set([
        //         .init(.init(node: PreviewData.id1, port: .output(0)), .init(node: PreviewData.id2, port: .input(0)))!
        //     ])
        // )
        // store.
        let store = NodeDataStore()
        var n1 = FlowNode(id: PreviewData.id1, kind: .addNode(.float))
        var n2 = FlowNode(id: PreviewData.id2, kind: .addNode(.float))
        store.addNode(n1)
        store.addNode(n2)
        _ = store.addEdge(
            .init(
                PortLocation(node: PreviewData.id1, port: .output(0)),
                PortLocation(node: PreviewData.id2, port: .input(0))
            )!
        )
        return store
    }()
    VStack {
        CanvasFeatureView(state: state, nodeDataStore: nodeDataStore)
    }
    .frame(width: 500, height: 500)
    .border(.gray.opacity(0.2))
    .padding()
}

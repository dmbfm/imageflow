import CanvasFeature
import Models
import NodeDataStore
import NodeSelectionStore
import SwiftUI

@Observable
final class DocumentState {
    var canvas: CanvasFeatureState = .init()
    var nodeData: NodeDataStore = .init()
    var nodeSelection: NodeSelectionStore = .init()

    init(
        canvas: CanvasFeatureState = .init(),
        nodeData: NodeDataStore = .init(),
        nodeSelection: NodeSelectionStore = .init()
    ) {
        self.canvas = canvas
        self.nodeData = nodeData
        self.nodeSelection = nodeSelection
    }
}

extension DocumentState {
    struct Snapshot: Codable, Sendable {
        var canvas: CanvasFeatureState.StorableData
        var nodeData: NodeDataStore.StorableData
        var nodeSelection: NodeSelectionStore.StorableData
    }

    func snapshot() -> Snapshot {
        .init(canvas: self.canvas, nodeData: self.nodeData, nodeSelection: self.nodeSelection)
    }

    func restore(_ snapshot: Snapshot) {
        self.canvas = snapshot.canvas
        self.nodeData = snapshot.nodeData
        self.nodeSelection = snapshot.nodeSelection
    }
}

// extension DocumentState: Storable {
//     struct StorableData: Codable, Sendable {
//         var canvas: CanvasFeatureState.StorableData
//         var nodeData: NodeDataStore.StorableData
//         var nodeSelection: NodeSelectionStore.StorableData
//     }

//     convenience init(_ data: StorableData) {
//         self.init(canvas: .init(data.canvas), nodeData: .init(data.nodeData), nodeSelection: .init(data.nodeSelection))
//     }

//     func snapshot() async throws -> StorableData {
//         try await .init(
//             canvas: self.canvas.snapshot(),
//             nodeData: self.nodeData.snapshot(),
//             nodeSelection: self.nodeSelection.snapshot()
//         )
//     }

//     func snapshotSync() -> StorableData {
//         .init(
//             canvas: self.canvas,
//             nodeData: self.nodeData,
//             nodeSelection: self.nodeSelection
//         )
//     }
// }

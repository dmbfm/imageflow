import CanvasFeature
import NodeDataStore
import NodeSelectionStore
import SwiftUI

@Observable
final class DocumentState {
    var canvas: CanvasFeatureState = .init()
    var nodeData: NodeDataStore = .init()
    var nodeSelection: NodeSelectionStore = .init()
}

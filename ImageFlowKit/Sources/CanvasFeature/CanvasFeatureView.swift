import CanvasView
import Design
import Logging
import Models
import NodeDataStore
import NodeView
import  PlatformUtils
import SwiftUI

import enum CanvasView.CoordinateSpace

public struct CanvasFeatureView: View {

    // MARK: - State 

    @Binding var state: CanvasFeatureState
    @Binding var nodeDataStore: NodeDataStore
    @State var edgeLayers: [EdgeLayer] = []
    @State var nodeViews: NodeViewCollection = .init()
    @State var canvasPlatformViewRef: PlatformViewRef = .init()

    // MARK: - Initializers
     
    public init(_ state: Binding<CanvasFeatureState>, _ nodeDataStore: Binding<NodeDataStore>) {
        self._state = state
        self._nodeDataStore = nodeDataStore
    }

    // MARK: - Node Views

    func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {

        if let view = self.nodeViews[id] {
            return view
        }

        guard let node = self.nodeDataStore.nodes[id] else {
            log("Node data not found for id: \(id)", level: .warning)
            return nil
        }

        let view = NodeView(node)

        view.emitter.on { event in
            log("node: \(id), event: \(event)")
            switch event {
            case .click: break
            case .dragGesture(_): break
            case .sizeChanged: break
            case .other(let event):
                switch event {
                case .valueDidChange(_, _): break
                }
            }
        }

        self.nodeViews[id] = view

        return view
    }


    // MARK: - Node Edges
    
    func updateEdges() {
        var edges = [
            EdgeLayer(
                color: Colors.portConnected.platformColor,
                edges: self.nodeDataStore.edges.map { edge in
                    Edge(
                        edge.id,
                        src: self.portFrameCenter(edge.from)!,
                        dst: self.portFrameCenter(edge.to)!
                    )
                }
            )
        ]

        // if let e = self.partialEdge {

        //     let point = self.state.viewport.convert(
        //         self.converter.convertFromWindow(e.point),
        //         from: .screen,
        //         to: .canvas
        //     )
        //     let (src, dst) =
        //         switch e.port.slot {
        //         case .input:
        //             (point, self.portFrameCenter(e.port)!)
        //         case .output:
        //             (self.portFrameCenter(e.port)!, point)
        //         }

        //     edges.append(
        //         .init(color: e.color, edges: [.init(src: src, dst: dst)])
        //     )
        // }

        self.edgeLayers = edges

        log("edge layers updated: \(self.edgeLayers)")
    }

    // MARK: - Port

    func portFrame(_ location: PortLocation) -> CGRect? {
        guard let frame = self.nodeViews[location.node]?.portFrame(location.slot) else {
            return nil
        }
        return self.canvasPlatformViewRef.view?.convert(frame, from: nil)
    }

    func portFrameCenter(_ location: PortLocation, _ coordinateSpace: CoordinateSpace = .canvas) -> CGPoint? {
        guard let frame = self.portFrame(location) else { return nil }
        return self.state.viewport.convert(frame.center, from: .screen, to: coordinateSpace)
    }


    public var body: some View {
        ZStack {
            CanvasView(
                self.$state.viewport,
                self.$state.nodePositions,
                self.edgeLayers,
                self.canvasPlatformViewRef,
                self.viewForNode
            )
            .onChange(of: self.nodeDataStore.edges, initial: true) { self.updateEdges() }
            .onChange(of: self.state.nodePositions, initial: true) { self.updateEdges() }
        }
    }
}

enum PreviewData {
    static let id = UUID()
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var state: CanvasFeatureState = .init(nodePositions: [PreviewData.id: .zero])
    @Previewable @State var nodeDataStore: NodeDataStore = .init([
        PreviewData.id: .init(id: PreviewData.id, kind: .addNode(.float))
    ])
    VStack {
        CanvasFeatureView($state, $nodeDataStore)
    }
}

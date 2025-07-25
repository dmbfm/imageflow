import Logging
import Models
import NodeControls
import SwiftUI

private let labelSize: CGFloat = 10

extension EnvironmentValues {
    @Entry var nodeID: UUID = .init()
    @Entry var portPositionStorage: (any PortPositionStorageProtocol)? = nil
    @Entry var portDragGesture: PortDragGesture? = nil
}

extension View {
    public func portDragGesture(_ handler: @escaping (PortDragGesture.Value, PortDragGesture.Phase) -> ()) -> some View
    {
        self
            .environment(\.portDragGesture, .init(handler: handler))
    }

    public func portPositionStorage(_ storage: (PortPositionStorageProtocol)?) -> some View {
        self
            .environment(\.portPositionStorage, storage)
    }
}

public struct PortDragGesture {

    public var handler: (Value, Phase) -> ()

    public struct Value: Sendable, Equatable {
        public var port: PortLocation
        public var location: CGPoint
    }

    public enum Phase: Sendable, Equatable {
        case started
        case cancelled
        case changed
        case ended
    }

    public init(handler: @escaping (Value, Phase) -> ()) {
        self.handler = handler
    }
}

@MainActor
public protocol PortPositionStorageProtocol: AnyObject {
    func updatePortPosition(_ location: PortLocation, _ position: CGPoint)
}

public struct NodeView: View {

    @Binding var node: FlowNode
    @State var contentWidth: CGFloat = 0

    public init(node: Binding<FlowNode>) {
        self._node = node
    }

    public var body: some View {
        VStack(alignment: .leading) {
            NodeTitleView(
                title: self.node.name,  // "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR",  //self.node.name,
                subtitle: self.node.kind.displayName,
                icon: self.node.kind.icon,
                tintColor: self.node.kind.frontendNodeColor
            )
            .padding(8)
            .padding(.top, 18)
            .frame(width: self.contentWidth, alignment: .leading)

            NodeContentView(node: self.$node)
                .padding(.bottom, 12)
                .measureWidth(storeIn: self.$contentWidth)
        }
        .nodeCard(tintColor: self.node.kind.frontendNodeColor)
        .tint(self.node.kind.frontendNodeColor)
        .environment(\.nodeID, self.node.id)
    }
}

fileprivate struct NodeContentView: View {
    @Binding var node: FlowNode

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            NodeInputRowsBlockView(inputs: self.$node.inputs)
            NodeOutputRowsBlockView(outputs: self.node.outputs)
        }
    }
}

fileprivate struct NodeInputRowsBlockView: View {

    @Binding var inputs: [FlowNode.Input]
    @FocusState var focusedRow: Int?
    @Environment(\.nodeID) var nodeID
    @Environment(\.portPositionStorage) var portPositionStorage

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(self.$inputs) { $input in
                GridRow(alignment: .center) {
                    NodeInputRowView(input: $input, port: .init(node: self.nodeID, port: .input(input.id)))
                        .onPortPositionChanged { point in
                            self.portPositionStorage?.updatePortPosition(
                                .init(node: self.nodeID, port: .input(input.id)),
                                point
                            )
                        }
                        .focused(self.$focusedRow, equals: input.id)
                        .zIndex(self.focusedRow == input.id ? .infinity : 0)
                }
                .frame(height: 18)
            }
        }
        .padding(.trailing, 14)
    }
}

fileprivate struct NodeInputRowView: View {

    @Binding var input: FlowNode.Input
    @FocusState var isFocused: Bool
    let port: PortLocation

    var body: some View {
        HStack(spacing: 2) {
            PortView(connected: self.input.connected, port: self.port)
            Text(input.label)
                .fixedSize()
                .font(.system(size: labelSize, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .gridColumnAlignment(.leading)
        .padding(.trailing, 20)

        Group {
            switch input.value.type {
            case .float:
                if input.label == "angle" {
                    NodeAngleInput(value: $input.value.float, mode: .compact)
                } else {
                    NodeNumberInput(value: $input.value.float)
                        .focused(self.$isFocused, equals: true)
                }
            case .vector2:
                NodeVectorInput(vector2: $input.value.vector2)
            case .image:
                NodeImageInput(value: $input.value.image)
            default:
                Text("TODO: \(input.value.type)")
                    .font(.system(size: 10))
                    .fixedSize()
            }
        }
        .gridColumnAlignment(.leading)

        // TextField("", text: .constant("2555"))
        //     .font(.system(size: 10))
        //     .fixedSize()
        //     .padding(.leading, 20)
    }
}

fileprivate struct NodeOutputRowsBlockView: View, Equatable {
    static nonisolated func == (lhs: NodeOutputRowsBlockView, rhs: NodeOutputRowsBlockView) -> Bool {
        MainActor.assumeIsolated {
            lhs.outputs == rhs.outputs
        }
    }

    let outputs: [FlowNode.Output]
    @Environment(\.nodeID) var nodeID
    @Environment(\.portPositionStorage) var portPositionStorage

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(self.outputs, id: \.label) { output in
                GridRow {
                    NodeOutputRowView(output: output, port: .init(node: self.nodeID, port: .output(output.index)))
                        .onPortPositionChanged { point in
                            self.portPositionStorage?.updatePortPosition(
                                .init(node: self.nodeID, port: .output(output.id)),
                                point
                            )
                        }
                }
            }
        }
        .frame(alignment: .trailing)
    }
}

fileprivate struct NodeOutputRowView: View, Equatable {
    let output: FlowNode.Output
    let port: PortLocation
    var body: some View {
        // Spacer()
        Text("")
        HStack(spacing: 2) {
            Text(output.label)
                .font(.system(size: labelSize))
                .foregroundStyle(.secondary)
            PortView(connected: self.output.connected, port: self.port)
        }
        .gridColumnAlignment(.trailing)
    }
}

// MARK: - Utils

private struct WidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func measureWidth(storeIn width: Binding<CGFloat>) -> some View {
        self
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: WidthKey.self, value: proxy.size.width)
                        .onPreferenceChange(
                            WidthKey.self,
                            perform: { value in
                                width.wrappedValue = value
                            }
                        )
                }
            )
    }
}

// MARK: - Preview

#Preview {

    @Previewable @State var node: FlowNode = .init(kind: .coreImageFilterNode(.dotScreen))

    NodeView(node: $node)
        .padding(100)
}

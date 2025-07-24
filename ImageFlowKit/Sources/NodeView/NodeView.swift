import Models
import NodeControls
import SwiftUI

let labelSize: CGFloat = 10

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
    }
}

extension NodeView: @preconcurrency Equatable {
    public static func == (lhs: NodeView, rhs: NodeView) -> Bool {
        lhs.node == rhs.node && lhs.contentWidth == rhs.contentWidth
    }
}

fileprivate struct NodeContentView: View, @preconcurrency Equatable {
    @Binding var node: FlowNode

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.node == rhs.node
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            NodeInputRowsBlockView(inputs: self.$node.inputs)
            NodeOutputRowsBlockView(outputs: self.node.outputs)
        }
    }
}

fileprivate struct NodeInputRowsBlockView: View {

    @Binding var inputs: [FlowNode.Input]
    @FocusState var focusedRow: String?

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(self.$inputs) { $input in
                GridRow(alignment: .center) {
                    NodeInputRowView(input: $input)
                        .focused(self.$focusedRow, equals: input.id)
                        .zIndex(self.focusedRow == input.id ? .infinity : 0)
                    // .border(self.focusedRow == input.id ? .red.opacity(0.25) : .clear)
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

    var body: some View {
        HStack(spacing: 2) {
            PortView(connected: false)
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

fileprivate struct NodeOutputRowsBlockView: View {
    let outputs: [FlowNode.Output]

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(self.outputs, id: \.label) { output in
                GridRow {
                    NodeOutputRowView(output: output)
                }
            }
        }
        .frame(alignment: .trailing)
    }
}

fileprivate struct NodeOutputRowView: View, Equatable {
    let output: FlowNode.Output
    var body: some View {
        // Spacer()
        Text("")
        HStack(spacing: 2) {
            Text(output.label)
                .font(.system(size: labelSize))
                .foregroundStyle(.secondary)
            PortView(connected: false)
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

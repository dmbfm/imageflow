import Models
import SwiftUI

public struct NodeView: View {

    @Binding var node: FlowNode
    @State var contentWidth: CGFloat = 0

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

fileprivate struct NodeInputRowsBlockView: View, @preconcurrency Equatable {
    static func == (lhs: NodeInputRowsBlockView, rhs: NodeInputRowsBlockView) -> Bool {
        lhs.inputs == rhs.inputs
    }

    @Binding var inputs: [FlowNode.Input]

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(self.$inputs) { $input in
                GridRow(alignment: .center) {
                    NodeInputRowView(input: $input)
                }
            }
        }
        .padding(.trailing, 14)
    }
}

fileprivate struct NodeInputRowView: View, @preconcurrency Equatable {
    @Binding var input: FlowNode.Input

    static func == (lhs: NodeInputRowView, rhs: NodeInputRowView) -> Bool {
        lhs.input == rhs.input
    }

    var body: some View {
        HStack(spacing: 2) {
            PortView(connected: false)
            Text(input.label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .gridColumnAlignment(.leading)

        TextField("", text: .constant("2555"))
            .font(.system(size: 10))
            .fixedSize()
            .padding(.leading, 20)
    }
}

fileprivate struct NodeOutputRowsBlockView: View, Equatable {
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
                .font(.system(size: 10))
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

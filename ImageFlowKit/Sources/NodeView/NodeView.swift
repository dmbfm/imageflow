import Models
import SwiftUI

public struct NodeView: View {

    @Binding var node: FlowNode
    @State var text = "255"

    public var body: some View {
        VStack {
            NodeTitleView(
                title: self.node.name,
                subtitle: self.node.kind.displayName,
                icon: self.node.kind.icon,
                tintColor: self.node.kind.frontendNodeColor
            )
            .padding(8)
            .padding(.top, 18)

            Grid(horizontalSpacing: 0, verticalSpacing: 0) {

                ForEach(self.$node.inputs) { $input in
                    GridRow(alignment: .center) {
                        HStack(spacing: 2) {
                            PortView(connected: false)
                            Text(input.label)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .gridColumnAlignment(.leading)
                        TextField("", text: self.$text)
                            .font(.system(size: 10))
                            .fixedSize()
                    }
                }
                
                GridRow {Text("")}
                    .padding(.top, 2)
                
                ForEach(self.node.outputs, id: \.label) { output in
                    GridRow {
                        Text("")
                        HStack {
                            Text(output.label)
                               .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            PortView(connected: false)
                        }
                        .gridColumnAlignment(.leading)
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .nodeCard(tintColor: self.node.kind.frontendNodeColor)
    }
}

extension NodeView: @preconcurrency Equatable {
    public static func == (lhs: NodeView, rhs: NodeView) -> Bool {
        lhs.node == rhs.node
    }
}

#Preview {
    @Previewable @State var node: FlowNode = .init(kind: .coreImageFilterNode(.dotScreen))

    NodeView(node: $node)
        .padding(100)
}

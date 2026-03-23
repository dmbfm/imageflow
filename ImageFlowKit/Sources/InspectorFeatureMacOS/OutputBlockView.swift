import InspectorFeatureShared
import SharedModels
import SwiftUI
import Values

struct OutputBlockView: View {

    let vm: InspectorFeatureViewModel

    var body: some View {
        InspectorBlock("Outputs") {
            VStack(alignment: .leading) {
                ForEach(self.vm.node.outputs) { output in
                    HStack(alignment: .firstTextBaseline) {
                        InspectorPropertyLabel(label: output.label)

                        Text(output.type.displayName.uppercased())
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color(white: 0.13))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background {
                                Color(white: 0.45)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Spacer()

                        OutputConnectedNodeButton(vm: self.vm, output: output)
                    }
                }
            }
        }
    }
}

struct OutputConnectedNodeButton: View {
    let vm: InspectorFeatureViewModel
    let output: FlowNode.Output

    var nodes: [Item] {
        self.vm.flow
            .edges(ofPort: .init(node: self.vm.node.id, port: .output(output.index)))
            .map({ $0.to.node })
            .compactMap({ self.vm.flow.nodes[$0] })
            .map({ .init(id: $0.id, name: $0.name) })
    }

    struct Item {
        var id: UUID
        var name: String
    }

    var body: some View {
        if nodes.count == 1 {
            ConnectedNodeButton(connected: output.connected) {
                if let first = self.nodes.first {
                    self.vm.flow.select([first.id])
                }
            }
        } else if nodes.count > 1 {
            Menu {
                ForEach(self.nodes, id: \.id) { node in
                    Button(node.name) {
                        self.vm.flow.select([node.id])
                    }
                }
            } label: {
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .help("Select the connected node.")
            .menuIndicator(.hidden)
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.plain)
            .padding(.leading, 0)
        }
    }
}

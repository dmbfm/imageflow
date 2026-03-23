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
                    HStack(alignment: .bottom) {
                        InspectorPropertyLabel(label: output.label)

                        Pill(text: output.type.displayName.uppercased())

                        Spacer()

                        OutputConnectedNodeButton(vm: self.vm, output: output)
                    }
                }
            }
        }
    }
}

struct Pill: View {

    var text: String
    @Environment(\.colorScheme) var cs

    var bg: Color {
        switch self.cs {
        case .dark:
            Color(white: 0.45)
        default:
            Color(white: 0.45)
        }
    }

    var fg: Color {
        switch self.cs {
        case .dark:
            Color(white: 0.13)
        default:
            Color(white: 0.90)
        }
    }

    var body: some View {
        Text(text)
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(self.fg)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background {
                self.bg
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
        if nodes.count == 0 {
            Button {
            } label: {
                Image(systemName: "arrow.right.circle.dotted")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .help("Select the connected node.")
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.borderless)
            .disabled(true)
        }
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

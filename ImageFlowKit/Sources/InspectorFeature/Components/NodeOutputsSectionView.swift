import SharedModels
import SwiftUI

struct NodeOutputsSectionView: View {

    let vm: InspectorFeatureViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Outputs")
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                    .foregroundStyle(.primaryLabel)
                Spacer()
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 0)

            ForEach(self.vm.node.outputs) { output in
                NodeOutputSlotView(vm: self.vm, output: output)
            }
        }
    }
}

struct NodeOutputSlotView: View {

    let vm: InspectorFeatureViewModel
    let output: FlowNode.Output

    var connected: Bool {
        self.output.connected
    }

    var name: String {
        self.output.label
    }

    var icon: String {
        if self.connected {
            "arrow.forward.circle"
        } else {
            "circle.dotted"
        }
    }

    var typeName: String {
        self.output.type.displayName
    }

    func onTapConnectedButton() {
        self.vm.flow.select(nodeConnectedToNode: self.vm.node.id, atOutputPort: self.output.index)
    }

    var body: some View {
        Block {
            HStack(spacing: 4) {
                Button {
                    self.onTapConnectedButton()
                } label: {
                    Image(systemName: self.icon)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondaryLabel)
                }
                .buttonStyle(.plain)
                .environment(\.isEnabled, self.connected)

                HStack {
                    Text(self.name)
                        .font(.system(size: 12))
                        .foregroundStyle(.primaryLabel)

                    Pill(text: self.typeName)
                }
            }
        }
    }
}

struct Pill: View {

    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 8, weight: .bold).smallCaps())
            .foregroundStyle(.secondaryLabel)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(.primaryFill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

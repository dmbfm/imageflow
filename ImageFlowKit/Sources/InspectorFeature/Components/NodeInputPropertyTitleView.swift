import SharedModels
import SwiftUI

struct NodeInputPropertyTitleView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        NodeInputPropertyTitleInner(name: input.label, connected: input.connected) {
            self.vm.flow.select(nodeConnectedToNode: self.vm.node.id, atInputPort: self.input.index)
        }
    }
}

private struct NodeInputPropertyTitleInner: View {

    var name: String
    var connected: Bool
    var onTapConnectedButton: (() -> ())?

    var icon: String {
        if self.connected {
            "arrow.backward.circle"
        } else {
            "circle.dotted"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Button {
                self.onTapConnectedButton?()
            } label: {
                Image(systemName: self.icon)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondaryLabel)
            }
            .buttonStyle(.plain)
            .disabled(!self.connected)

            Text(self.name)
                .font(.system(size: 12))
                .foregroundStyle(.primaryLabel)
        }
    }
}

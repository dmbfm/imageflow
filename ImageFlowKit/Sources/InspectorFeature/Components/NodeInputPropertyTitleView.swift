import SharedModels
import SwiftUI
import Values

struct NodeInputPropertyTitleView: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var defaultValue: Value? {
        let schema = self.vm.node.kind.schema
        if !schema.inputs.indices.contains(self.input.index) {
            return nil
        }

        let inputSchema = schema.inputs[self.input.index]

        return inputSchema.defaultValue ?? inputSchema.type.defaultValue
    }

    var changed: Bool {
        self.input.value != self.defaultValue
    }

    func restoreDefaultValue() {
        if let defaultValue = self.defaultValue {
            self.vm.submit(.input(self.input.index, defaultValue, nil), registerUndo: true)
        }
    }

    var body: some View {
        NodeInputPropertyTitleInner(name: input.label, connected: input.connected, changed: self.changed) {
            self.vm.flow.select(nodeConnectedToNode: self.vm.node.id, atInputPort: self.input.index)
        } onTapRestoreButton: {
            self.restoreDefaultValue()
        }
    }
}

private struct NodeInputPropertyTitleInner: View {

    var name: String
    var connected: Bool
    var changed: Bool
    var onTapConnectedButton: (() -> ())?
    var onTapRestoreButton: (() -> ())?

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
            .environment(\.isEnabled, self.connected)

            Text(self.name)
                .font(.system(size: 12))
                .foregroundStyle(.primaryLabel)

            if self.changed {
                Button {
                    self.onTapRestoreButton?()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderless)
                .help("Restore default value")
            }
        }
    }
}

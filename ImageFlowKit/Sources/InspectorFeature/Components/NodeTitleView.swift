import Logging
import SharedModels
import SwiftUI

struct NodeTitleView: View {

    let vm: InspectorFeatureViewModel
    @Environment(\.inspectorStyle) var style
    @FocusState var textFieldFocused

    var node: FlowNode {
        self.vm.node
    }

    var lockIcon: String {
        if self.vm.isLocked {
            "lock"
        } else {
            "lock.open"
        }
    }

    var nodeName: Binding<String> {
        .init(
            get: {
                self.vm.node.name
            },
            set: { newValue in
                self.vm.node.name = newValue
            }
        )
    }

    func submitNodeName() {
        self.vm.submit(.name, registerUndo: true)
        self.textFieldFocused = false
    }

    func cancelNodeName() {
        self.vm.cancel(.name)
    }

    var body: some View {
        HStack {
            Image(systemName: node.kind.icon)
                .foregroundStyle(.secondaryLabel)
                .font(.headline)

            TextField("", text: self.nodeName)
                .textFieldStyle(kind: .plain)
                .textContentType(.password)
                .focused(self.$textFieldFocused)
                .onSubmit(self.submitNodeName)
                .font(.headline)
                .foregroundStyle(.primaryLabel)
                #if os(macOS)
            .onExitCommand {
                self.cancelNodeName()
                self.textFieldFocused = false
            }
                #endif
            Spacer()

            HStack(spacing: 0) {
                Button("", systemImage: self.lockIcon) {
                    self.vm.toggleLocked()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondaryLabel)

                InspectorNodeMenuButton(vm: self.vm)
            }
        }
        .padding(.horizontal, self.style.paddingHorizontal)
        .padding(.top, self.style.paddingTop)
        .padding(.bottom, self.style.paddingNodeTitleBottom)
    }
}

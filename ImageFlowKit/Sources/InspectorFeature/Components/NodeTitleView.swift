import SwiftUI
import SharedModels
import Logging

struct NodeTitleView: View {

    @Environment(\.inspectorStyle) var style
    let vm: InspectorFeatureViewModel

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

    var body: some View {
        HStack {
            Image(systemName: node.kind.icon)
                .foregroundStyle(.secondaryLabel)
                .font(.headline)

            Text(node.name)
                .font(.headline)
                .foregroundStyle(.primaryLabel)

            Spacer()

            Button("", systemImage: self.lockIcon) {
                self.vm.toggleLocked()
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondaryLabel)

            Button("", systemImage: "ellipsis") {
                log("TODO", level: .error)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondaryLabel)
        }
        .padding(.horizontal, self.style.paddingHorizontal)
        .padding(.top, self.style.paddingTop)
        .padding(.bottom, self.style.paddingNodeTitleBottom)
    }
}


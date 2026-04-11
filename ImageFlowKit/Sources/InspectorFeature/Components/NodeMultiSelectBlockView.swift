import SharedModels
import SwiftUI

struct NodeMultiSelectBlockView: View {

    let vm: InspectorFeatureViewModel

    var items: [Item] {
        self.vm.flow.selection.compactMap({ id in
            self.vm.flow.nodes[id].map({
                .init(id: id, name: $0.name)
            })
        })
    }

    var selected: Binding<UUID> {
        .init(
            get: {
                self.vm.node.id
            },
            set: { id in
                if let node = self.vm.flow.nodes[id] {
                    self.vm.node = node
                }
            }
        )
    }

    struct Item: Identifiable {
        var id: UUID
        var name: String
    }

    var body: some View {
        Block {
            HStack {
                Text("Node")
                    .font(.system(size: 12))
                    .foregroundStyle(.primaryLabel)
                Spacer()
                Picker("", selection: self.selected) {
                    ForEach(self.items) { item in
                        Text(item.name).tag(item.id)
                    }
                }
                .controlSize(.small)
            }
        }
    }
}

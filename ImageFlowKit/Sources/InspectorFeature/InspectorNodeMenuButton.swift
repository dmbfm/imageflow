import SharedModels
import SwiftUI

public struct InspectorNodeMenuButton: View {
    let node: FlowNode
    let vm: InspectorFeatureViewModel

    public init(node: FlowNode, vm: InspectorFeatureViewModel) {
        self.node = node
        self.vm = vm
    }

    public var body: some View {
        Menu {
            Button("Cut Node", systemImage: .systemIconMenuCut) {
                self.vm.coordinator.perform(userAction: .cut(.node(self.vm.node.id)))
            }
            Button("Copy Node", systemImage: .systemIconMenuCopy) {
                self.vm.coordinator.perform(userAction: .copy(.node(self.vm.node.id)))
            }
            Button("Duplicate Node", systemImage: .systemIconMenuDuplicate) {
                self.vm.coordinator.perform(userAction: .duplicate(.node(self.vm.node.id)))
            }
            Button("Delete Node", systemImage: .systemIconMenuDelete, role: .destructive) {
                self.vm.coordinator.perform(userAction: .delete(.node(self.vm.node.id)))
            }
        } label: {
            Image(systemName: "ellipsis")
                #if os(iOS)
            .frame(height: 25)
            .contentShape(Rectangle())
                #endif
        }
        #if os(iOS)
        .buttonStyle(.plain)
        #else
        .buttonStyle(.borderless)
        .menuIndicator(.hidden)
        #endif
    }
}

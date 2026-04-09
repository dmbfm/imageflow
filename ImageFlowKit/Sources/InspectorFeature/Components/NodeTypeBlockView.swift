import Backend
import SharedModels
import SwiftUI

public struct NodeTypeBlockView: View {

    let vm: InspectorFeatureViewModel

    var nodeKind: Binding<NodeKind> {
        .init(
            get: {
                self.vm.node.kind
            },
            set: { newValue in
                self.vm.flow.convertNodeAction(self.vm.node.id, kind: newValue, undoManager: self.vm.undoManager)
            }
        )
    }

    var kinds: [NodeKind] {
        self.vm.node.variations
    }

    public var body: some View {
        Block {
            HStack {
                Text("Type")
                    .font(.system(size: 12))
                    .foregroundStyle(.primaryLabel)
                Spacer()

                switch self.kinds.count {
                case 1:
                    Text(self.kinds[0].displayName)
                case let n where n > 1:
                    Picker("", selection: self.nodeKind) {
                        ForEach(self.kinds, id: \.self) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                default:
                    EmptyView()
                }
            }
        }
        .controlSize(.small)
    }
}

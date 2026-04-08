import SharedModels
import SwiftUI
import Values

struct AssetInputView: View {

    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    @Environment(\.isEnabled) var isEnabled

    var id: AssetIdentifier? {
        switch self.input.value {
        case .image(let id): id
        case .lut(let id): id
        default: nil
        }
    }

    var label: String {
        if let id = self.id {
            self.vm.assetStore.titleForAsset(id: id) ?? id.id.uuidString
        } else {
            "Select..."
        }
    }

    var assetKind: AssetKind? {
        switch self.input.value.type {
        case .image: .image
        case .lut: .lut
        default: nil
        }
    }

    func assetButtonAction() {
        if let kind = self.assetKind {
            self.vm.coordinator.perform(
                userAction: .openAssetPicker(
                    node: self.vm.node.id,
                    portIndex: self.input.index,
                    kind: kind
                )
            )
        }
    }

    func value(_ id: AssetIdentifier?) -> Value? {
        switch self.input.value.type {
        case .image: .image(id)
        case .lut: .lut(id)
        default: nil
        }
    }

    var body: some View {
        Block {
            VStack(alignment: .leading) {
                HStack {
                    NodeInputPropertyTitleView(vm: self.vm, input: self.input)
                }
                if self.isEnabled {
                    HStack {
                        Spacer()
                        Button {
                            self.assetButtonAction()
                        } label: {
                            HStack {
                                Spacer()
                                Text(self.label)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Button {
                            if let value = self.value(nil) {
                                self.vm.submit(.input(self.input.index, value, nil), registerUndo: true)
                            }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                    .controlSize(.small)
                }
            }
        }
    }
}

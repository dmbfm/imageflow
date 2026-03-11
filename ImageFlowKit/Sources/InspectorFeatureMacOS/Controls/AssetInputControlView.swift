import InspectorFeatureShared
import SharedModels
import SwiftUI
import Values

protocol AssetInputControlViewType {
    static var kind: AssetKind { get }
    static func resolve(_ value: Value) -> AssetIdentifier?
    static func value(_ identifier: AssetIdentifier?) -> Value
}

struct ImageAssetInputType: AssetInputControlViewType {
    static var kind: SharedModels.AssetKind { .image }

    static func resolve(_ value: Values.Value) -> Values.AssetIdentifier? {
        if case let .image(id) = value {
            id
        } else {
            nil
        }
    }

    static func value(_ identifier: Values.AssetIdentifier?) -> Values.Value {
        .image(identifier)
    }
}

struct LUTAssetInputType: AssetInputControlViewType {
    static var kind: SharedModels.AssetKind { .lut }

    static func resolve(_ value: Values.Value) -> Values.AssetIdentifier? {
        if case let .lut(id) = value {
            id
        } else {
            nil
        }
    }

    static func value(_ identifier: Values.AssetIdentifier?) -> Values.Value {
        .lut(identifier)
    }
}

struct AssetInputControlView<AssetType: AssetInputControlViewType>: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var label: String {
        if let id = AssetType.resolve(input.value) {
            self.vm.coordinator.titleForAsset(id: id) ?? ""
        } else {
            "Select..."
        }
    }

    var hasAsset: Bool {
        AssetType.resolve(self.input.value) != nil
    }

    func removeButtonHandler() {
        self.vm.submit(.input(self.input.index, AssetType.value(nil), nil), registerUndo: true)
    }

    var body: some View {
        HStack {
            if !self.input.connected {
                Button(self.label) {
                    self.vm.coordinator.perform(
                        userAction: .openAssetPicker(
                            node: self.vm.node.id,
                            portIndex: self.input.index,
                            kind: AssetType.kind
                        )
                    )
                }

                if self.hasAsset {
                    Button {
                        self.removeButtonHandler()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .controlSize(.small)
    }
}

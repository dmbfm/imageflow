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

    public init(input: FlowNode.Input, vm: InspectorFeatureViewModel) {
        self.vm = vm
        self.input = input
    }

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

    private func buttonHandler(_ target: InputViewInner.Target) {
        switch target {
        case .label:

            self.vm.coordinator.perform(
                userAction: .openAssetPicker(
                    node: self.vm.node.id,
                    portIndex: self.input.index,
                    kind: AssetType.kind
                )
            )

        case .remove:
            self.removeButtonHandler()
        }
    }

    var body: some View {
        LabeledContent {
            InputViewInner(
                connected: self.input.connected,
                hasAsset: self.hasAsset,
                label: self.label,
                onButton: self.buttonHandler(_:)
            )
        } label: {
            InputLabel(input: self.input, vm: self.vm)
        }
    }
}

private struct InputViewInner: View {

    let connected: Bool
    let hasAsset: Bool
    let label: String

    var onButton: ((Target) -> ())?

    enum Target {
        case label
        case remove
    }

    @Environment(\.colorScheme) var cs

    var buttonStyle: any PrimitiveButtonStyle {
        self.cs == .dark ? BorderedButtonStyle() : BorderedProminentButtonStyle()
    }

    var body: some View {
        if !self.connected {
            HStack(spacing: 10) {
                Button(self.label) {
                    self.onButton?(.label)
                }
                .font(.system(size: 15))
                .buttonStyle(.borderless)
                .tint(.orange)

                if self.hasAsset {
                    HStack {
                        Button {
                            self.onButton?(.remove)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.borderless)
                        .tint(.secondary)
                    }
                }
            }
            .animation(.linear(duration: 0.15), value: self.hasAsset)
        }
    }
}

#Preview {
    @Previewable @State var connected: Bool = false
    @Previewable @State var hasAsset: Bool = true
    VStack {
        List {
            LabeledContent {
                InputViewInner(connected: connected, hasAsset: hasAsset, label: "Some Asset")
            } label: {
                Text("Image")
            }
        }
    }
    .frame(width: 400)
    VStack {
        Toggle("connected", isOn: $connected)
        Toggle("hasAsset", isOn: $hasAsset)
    }
}

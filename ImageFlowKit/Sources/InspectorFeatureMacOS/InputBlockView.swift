import InspectorFeatureShared
import SharedModels
import SwiftUI
import Values

struct InputBlockView: View {

    let vm: InspectorFeatureViewModel

    var configuration: BlockGridLayout.Configuartion {
        .init(
            horizontalSpacing: .init().with(\.control, 4),
            labelWidthPercent: 0.45,
            properties: self.vm.node.inputs.map({ input in
                switch input.value.type {
                case .vector2:
                    return .rows(2)
                case .vector3:
                    return .rows(3)
                case .vector4:
                    return .rows(4)
                case .rect:
                    return .rows(4)
                case .matrix3x3:
                    return .rows(3)
                case .matrix5x5:
                    return .rows(5)
                case .matrix7x7:
                    return .largeControl
                default:
                    return .rows(1)
                }
            })
        )
    }

    var body: some View {
        InspectorBlock("Inputs") {
            BlockGridLayout(self.configuration) {
                ForEach(self.vm.node.inputs) { input in
                    self.gridRow(input)
                }
            }
        }
    }

    @ViewBuilder
    func gridRow(_ input: FlowNode.Input) -> some View {
        switch input.value.type {
        case .vector2, .vector3, .vector4:
            VectorControlView(vm: self.vm, input: input)
                .disabled(input.connected)
        case .rect:
            RectInputControlView(vm: self.vm, input: input)
                .disabled(input.connected)
        case .matrix3x3:
            Matrix3x3InputControlView(vm: self.vm, input: input)
                .disabled(input.connected)
        case .matrix5x5:
            Matrix5x5InputControlView(vm: self.vm, input: input)
                .disabled(input.connected)
        case .float where input.semantics.isAngle:
            AngleInputControlView(vm: self.vm, input: input)
                .disabled(input.connected)
        default:
            self.gridSingleRow(input)
        }
    }

    @ViewBuilder
    func gridSingleRow(_ input: FlowNode.Input) -> some View {
        InspectorPropertyLabel(label: input.label)

        Text("")

        HStack(alignment: .center, spacing: 0) {
            SingleRowControl(vm: self.vm, input: input)
                .disabled(input.connected)
            Spacer(minLength: 0)
        }

        InputConnectedNodeButton(vm: self.vm, input: input)
    }
}

struct InputConnectedNodeButton: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        ConnectedNodeButton(connected: input.connected) {
            self.vm.flow.select(
                nodeConnectedToNode: self.vm.node.id,
                atInputPort: input.index
            )
        }
    }
}

struct ConnectedNodeButton: View {
    var connected: Bool
    var action: () -> ()

    var icon: String {
        self.connected ? "arrow.right.circle" : "arrow.right.circle.dotted"
    }

    var body: some View {
        Button {
            self.action()
        } label: {
            Image(systemName: self.icon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .help("Select the connected node.")
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.borderless)
        .disabled(!self.connected)
    }
}

struct InspectorPropertyLabel: View {
    var label: String
    var body: some View {
        Text(self.label)
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
    }
}

struct SingleRowControl: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        switch self.input.value.type {
        case .image:
            AssetInputControlView<ImageAssetInputType>(vm: self.vm, input: self.input)
        case .lut:
            AssetInputControlView<LUTAssetInputType>(vm: self.vm, input: self.input)
        case .float:
            FloatInputControlView(vm: self.vm, input: self.input)
        case .int:
            IntegerInputControlView(vm: self.vm, input: self.input)
        case .bool:
            BoolInputControlView(vm: self.vm, input: self.input)
        case .vector2, .vector3, .vector4:
            EmptyView()
        case .color4:
            ColorControlView(vm: self.vm, input: self.input)
        case .string:
            StringInputControlView(vm: self.vm, input: self.input)
        case .matrix7x7:
            Matrix7x7InputControlView(vm: self.vm, input: self.input)
        default:
            Text("TODO: \(input.value.type, default: "")")
        }
    }
}

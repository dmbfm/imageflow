import SharedModels
import SwiftUI
import Values

struct InputBlockView: View {

    let vm: InspectorFeatureViewModel

    @State var expanded: Bool = true

    var chevronIcon: String {
        self.expanded ? "chevron.down" : "chevron.right"
    }

    var configuration: BlockGridLayout.Configuartion {
        .init(
            horizontalSpacing: .init().with(\.control, 4),
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

    func onTapHeader() {
        self.expanded.toggle()
    }

    var body: some View {
        BlockContainer {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Image(systemName: self.chevronIcon)
                            .bold()
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 10))
                            .frame(width: 10)
                        Text("Inputs")
                            .bold()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.onTapHeader()
                    }
                    Spacer()
                }

                if self.expanded {
                    BlockGridLayout(self.configuration) {
                        ForEach(self.vm.node.inputs) { input in
                            self.gridRow(input)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    func gridRow(_ input: FlowNode.Input) -> some View {
        switch input.value.type {
        case .vector2, .vector3, .vector4:
            VectorControlView(vm: self.vm, input: input)
        case .rect:
            RectInputControlView(vm: self.vm, input: input)
        case .matrix3x3:
            Matrix3x3InputControlView(vm: self.vm, input: input)
        case .matrix5x5:
            Matrix5x5InputControlView(vm: self.vm, input: input)
        default:
            self.gridSingleRow(input)
        }
    }

    @ViewBuilder
    func gridSingleRow(_ input: FlowNode.Input) -> some View {
        InspectorInputTitle(input: input)

        Text("")

        HStack(alignment: .center, spacing: 0) {
            SingleRowControl(vm: self.vm, input: input)
                .disabled(input.connected)
            Spacer(minLength: 0)
        }

        ConnectedNodeButton(vm: self.vm, input: input)
    }
}

struct ConnectedNodeButton: View {
    let vm: InspectorFeatureViewModel
    let input: FlowNode.Input

    var body: some View {
        Button {
            self.vm.flow.select(
                nodeConnectedToNode: self.vm.node.id,
                atInputPort: input.index
            )
        } label: {
            Image(systemName: "arrow.right.circle")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .help("Select the connected node.")
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.borderless)
        .padding(.leading, 0)
        .disabled(!input.connected)
        .opacity(input.connected ? 1 : 0)
    }

}

struct InspectorInputTitle: View {
    var input: FlowNode.Input
    var body: some View {
        Text(input.label)
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

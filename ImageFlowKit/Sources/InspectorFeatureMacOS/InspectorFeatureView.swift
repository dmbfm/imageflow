import Backend
import Helpers
import InspectorFeatureShared
import Logging
import SharedMocking
import SharedModels
import SwiftUI
import Values

import class SharedModels.Flow

public struct InspectorFeatureView: View {

    @ObservableState var vm: InspectorFeatureViewModel

    @Environment(\.undoManager) var um

    public init(flow: Flow, coordinator: GlobalCoordinator) {
        self._vm = .init(wrappedValue: .init(flow: flow, coordinator: coordinator, undoManager: nil))
    }

    public var body: some View {
        Group {
            if self.vm.hasNode {
                self.content
            } else {
                ContentUnavailableView(
                    "No Node Selected",
                    systemImage: "list.bullet.rectangle.portrait.fill",
                    description: Text("Select a node to inspect it")
                )
            }
        }
        .onChange(of: self.um, initial: true) { self.vm.undoManager = um }
        // .background(Color.randomHue())
    }

    @ViewBuilder
    public var content: some View {
        VStack(spacing: 0) {

            self.headerView
                .padding(.horizontal, 12)
                .padding(.top, 12)

            ScrollView {
                self.nodeContentView
            }
        }
    }

    var headerView: some View {
        HeaderView(
            icon: self.vm.node.kind.icon,
            title: .init(
                get: {
                    self.vm.node.name
                },
                set: { newValue in
                    self.vm.node.name = newValue
                }
            ),
            onSubmitName: { [weak vm = self.vm] in
                vm?.submit(.name, registerUndo: true)
            },
            onCancelName: { [weak vm = self.vm] in vm?.cancel(.name) }
        )
    }

    @ViewBuilder
    var nodeContentView: some View {
        VStack(spacing: 0) {
            TypeBlockView(
                types: self.vm.node.variations,
                current: .init(
                    get: {
                        self.vm.node.kind
                    },
                    set: { _ in
                    }
                )
            )
            .padding(.bottom, 12)

            InputBlockView(vm: self.vm)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

struct HeaderView: View {

    let icon: String
    let title: Binding<String>
    var onSubmitName: () -> ()
    var onCancelName: () -> ()

    @FocusState var textFieldFocused: Bool

    internal init(
        icon: String,
        title: Binding<String>,
        onSubmitName: @escaping () -> (),
        onCancelName: @escaping () -> ()
    ) {
        self.icon = icon
        self.title = title
        self.onSubmitName = onSubmitName
        self.onCancelName = onCancelName
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: self.icon)
                .padding(.trailing, 8)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            TextField("", text: self.title)
                .textFieldStyle(.plain)
                .focused(self.$textFieldFocused)
                .onSubmit {
                    self.onSubmitName()
                    self.textFieldFocused = false
                }
                #if os(macOS)
            .onExitCommand {
                self.onCancelName()
                self.textFieldFocused = false
            }
                #endif
                .font(.headline)
            Spacer()
            Button("", systemImage: "lock") {}
                .buttonStyle(.borderless)
            Menu("", systemImage: "ellipsis") {
                Button("Delete") {}
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
        }
        .onChange(of: self.textFieldFocused, initial: false) {
            if !self.textFieldFocused {
                self.onSubmitName()
            }
        }
    }
}

struct TypeBlockView: View {

    var types: [NodeKind]
    @Binding var current: NodeKind

    var body: some View {
        BlockContainer {
            Text("Type")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.leading, 14)
            Spacer()

            switch self.types.count {
            case 1:
                Text(self.types[0].displayName)
            case let n where n > 1:
                Picker("", selection: self.$current) {
                    ForEach(self.types, id: \.self) { ty in
                        Text(ty.displayName)
                            .tag(ty)
                    }
                }
                .controlSize(.small)
            default:
                EmptyView()
            }
        }
    }
}

struct BlockContainer<Content: View>: View {
    var content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            HStack {
                self.content
            }
            .padding(.leading, 6)
            .padding(.trailing, 6)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

extension Flow {
    static func preview(_ kind: NodeKind) -> Flow {
        let flow = Flow()
        var node = FlowNode(kind: kind)
        node.inputs[2].connected = true
        flow.addNode(node, at: .zero)
        flow.select([node.id])
        return flow
    }
}

#Preview("Add Node") {
    @Previewable @State var flow: Flow = .preview(.math(.addNode(.float)))
    let coordinator: GlobalCoordinator = .init(MockGlobalCoordinatorService(flow: flow))
    InspectorFeatureView(flow: flow, coordinator: coordinator)
        .frame(width: 350)
}

#Preview("Float Node") {
    @Previewable @State var flow: Flow = .preview(.valueNode(.float))
    let coordinator: GlobalCoordinator = .init(MockGlobalCoordinatorService(flow: flow))
    InspectorFeatureView(flow: flow, coordinator: coordinator)
        .frame(width: 350)
}

#Preview("Color Matrix") {
    @Previewable @State var flow: Flow = .preview(.coreImageFilterNode(.colorAdjustment(.CIColorMatrix)))
    let coordinator: GlobalCoordinator = .init(MockGlobalCoordinatorService(flow: flow))
    InspectorFeatureView(flow: flow, coordinator: coordinator)
        .frame(width: 350)
}

#Preview("No Node Selected") {
    @Previewable @State var flow: Flow = .init()
    let coordinator: GlobalCoordinator = .init(MockGlobalCoordinatorService(flow: flow))
    InspectorFeatureView(flow: flow, coordinator: coordinator)
        .frame(width: 350)
}

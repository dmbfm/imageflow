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

    public init(flow: Flow, assetStore: (any AssetStoreService), coordinator: GlobalCoordinator) {
        self._vm = .init(
            wrappedValue: .init(flow: flow, coordinator: coordinator, assetStore: assetStore, undoManager: nil)
        )
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
    }

    @ViewBuilder
    public var content: some View {
        VStack(spacing: 0) {
            ScrollView {
                self.nodeContentView
            }
            .safeAreaBar(edge: .top) {
                HeaderView(vm: self.vm)
                    .padding(.horizontal, 12)
                    .padding(.top, 14)
                    .padding(.leading, 4)
                    .padding(.bottom, 4)
            }
            .safeAreaBar(edge: .bottom) {
                HStack {
                    Color(white: 1.0, opacity: 0.0001)
                }
                .frame(height: 20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }

    var selectionItems: [MultipleSelectionBlockView.Item] {
        self.vm.flow.selection.map({
            .init(id: $0, name: self.vm.flow.nodes[$0]?.name ?? $0.uuidString)
        })
    }

    @ViewBuilder
    var nodeContentView: some View {
        VStack(spacing: 0) {

            if self.vm.flow.selection.count > 1 {
                MultipleSelectionBlockView(
                    items: self.selectionItems,
                    current: .init(
                        get: {
                            self.vm.node.id
                        },
                        set: { id in
                            if let node = self.vm.flow.nodes[id] {
                                self.vm.node = node
                            }
                        }
                    )
                )
                .padding(.bottom, 12)
            }

            TypeBlockView(
                types: self.vm.node.variations,
                current: .init(
                    get: {
                        self.vm.node.kind
                    },
                    set: { newType in
                        self.vm.flow.convertNodeAction(self.vm.node.id, kind: newType, undoManager: self.vm.undoManager)
                    }
                )
            )
            .padding(.bottom, 12)

            InputBlockView(vm: self.vm)
                .padding(.bottom, 12)

            OutputBlockView(vm: self.vm)

            #if IF_INSPECTOR_DEBUG
            if self.vm.showDebugBlock {
                DebugBlockView(vm: self.vm)
                    .padding(.top, 12)
            }
            #endif

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

struct HeaderView: View {

    let vm: InspectorFeatureViewModel
    @FocusState var textFieldFocused: Bool

    var lockIcon: String {
        self.vm.isLocked ? "lock" : "lock.open"
    }

    var icon: String {
        self.vm.node.kind.icon
    }

    var title: Binding<String> {
        .init(
            get: {
                self.vm.node.name
            },
            set: { newValue in
                self.vm.node.name = newValue
            }
        )
    }

    func submitName() {
        self.vm.submit(.name, registerUndo: true)
    }

    func cancelName() {
        self.vm.cancel(.name)
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
                    self.submitName()
                    self.textFieldFocused = false
                }
                #if os(macOS)
            .onExitCommand {
                self.cancelName()
                self.textFieldFocused = false
            }
                #endif
                .font(.headline)
            Spacer()
            Button("", systemImage: self.lockIcon) {
                self.vm.toggleLocked()
            }
            .buttonStyle(.borderless)

            InspectorNodeMenuButton(node: self.vm.node, vm: self.vm)
        }
        .onChange(of: self.textFieldFocused, initial: false) {
            if !self.textFieldFocused {
                self.submitName()
            }
        }
    }
}

struct MultipleSelectionBlockView: View {

    var items: [Item]
    @Binding var current: UUID

    struct Item: Identifiable, Hashable {
        var id: UUID
        var name: String
    }

    var body: some View {
        BlockContainer {
            Text("Node")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.leading, 14)
            Spacer()
            Picker("", selection: self.$current) {
                ForEach(self.items, id: \.self) { item in
                    Text(item.name)
                        .tag(item.id)
                }
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
                    .font(.system(size: 14))
                    .padding(.trailing, 12)
                    .frame(height: 24)
            case let n where n > 1:
                Picker("", selection: self.$current) {
                    ForEach(self.types, id: \.self) { ty in
                        Text(ty.displayName)
                            .tag(ty)
                    }
                }
            default:
                EmptyView()
            }
        }
    }
}

extension Flow {
    static func preview(_ kind: NodeKind) -> Flow {
        let flow = Flow()
        let node = FlowNode(kind: kind)
        //        node.inputs[2].connected = true
        flow.addNode(node, at: .zero)
        flow.select([node.id])
        return flow
    }
}

extension InspectorFeatureView {

    struct Preview: View {
        @State var flow: Flow
        @State var coordinator: GlobalCoordinator
        @State var assetsProvider: MockAssetStore = .init()

        init(_ flow: Flow) {
            self._flow = .init(wrappedValue: flow)
            self._coordinator = .init(initialValue: .init(flow: flow))
        }
        var body: some View {
            InspectorFeatureView(flow: flow, assetStore: assetsProvider, coordinator: coordinator)
        }
    }
}

#Preview {
    @Previewable @State var flow: Flow = .preview(.coreImageFilterNode(.halftoneEffect(.CIDotScreen)))
    InspectorFeatureView.Preview(flow)
        .frame(width: 350)
}

#Preview("Float Node") {
    @Previewable @State var flow: Flow = .preview(.valueNode(.bool))
    InspectorFeatureView.Preview(flow)
        .frame(width: 350)
}

#Preview("Color Matrix") {
    @Previewable @State var flow: Flow = .preview(.coreImageFilterNode(.colorAdjustment(.CIColorMatrix)))
    InspectorFeatureView.Preview(flow)
        .frame(width: 350)
}

#Preview("No Node Selected") {
    @Previewable @State var flow: Flow = .init()
    InspectorFeatureView.Preview(flow)
        .frame(width: 350)
}

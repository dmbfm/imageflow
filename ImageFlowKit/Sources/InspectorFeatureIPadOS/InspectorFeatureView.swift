#if os(iOS)

import Backend
import Design
import Helpers
import InspectorFeatureShared
import SharedMocking
import SharedModels
import SwiftUI

public struct InspectorFeatureView: View {
    @ObservableState var vm: InspectorFeatureViewModel
    @Environment(\.undoManager) var undoManager
    @Environment(\.colorScheme) var cs

    public init(flow: SharedModels.Flow, assetStore: any AssetStoreService, coordinator: GlobalCoordinator) {
        self._vm = .init(
            wrappedValue: .init(flow: flow, coordinator: coordinator, assetStore: assetStore, undoManager: nil)
        )
    }

    public var body: some View {
        self.content
            .onChange(of: self.undoManager, initial: true) { self.vm.undoManager = self.undoManager }
    }

    @ViewBuilder
    var content: some View {
        if self.vm.hasNode {
            self.contentNodeView
        } else {
            ContentUnavailableView(
                "Node Inspector",
                systemImage: "list.bullet.rectangle.portrait.fill",
                description: Text("Select a node to inspect it")
            )
        }
    }

    @ViewBuilder
    var contentNodeView: some View {
        VStack {
            NodeFormView(vm: self.vm)
                .safeAreaBar(edge: .top) {
                    NodeHeaderView(node: self.vm.node, vm: self.vm)
                        .padding(.horizontal, 28)
                        .padding(.top, 28)
                }
                .clipped()
        }
    }
}

struct MultiSelectionSectionView: View {
    let vm: InspectorFeatureViewModel
    
    var items: [Item]
    @Binding var current: UUID

    struct Item: Identifiable, Hashable {
        var id: UUID
        var label: String
    }

    var body: some View {
        LabeledContent("Node") {
                Picker("", selection: self.$current) {
                    ForEach(self.items, id: \.self) { item in
                        Text(item.label)
                            .tag(item.id)
                    }
                }
        }
    }
}

struct TypeSectionView: View {
    let vm: InspectorFeatureViewModel

    var types: [NodeKind] {
        self.vm.node.variations
    }

    var binding: Binding<NodeKind> {
        .init(
            get: {
                self.vm.node.kind
            },
            set: { newValue in
                self.vm.flow.convertNodeAction(self.vm.node.id, kind: newValue, undoManager: self.vm.undoManager)
            }
        )
    }

    var body: some View {
        LabeledContent("Type") {
            if types.count <= 1 {
                Text(self.vm.node.kind.displayName)
            } else {
                Picker("", selection: self.binding) {
                    ForEach(self.types, id: \.self) { ty in
                        Text(ty.displayName)
                            .tag(ty)
                    }
                }
            }
        }
    }
}

struct NodeFormView: View {

    let vm: InspectorFeatureViewModel
    @Environment(\.colorScheme) var cs
    
    var selectedItems: [MultiSelectionSectionView.Item] {
        self.vm.flow.selection.map({
            .init(id: $0, label: self.vm.flow.nodes[$0]?.name ?? $0.uuidString)
        })
    }
    
    var currentItem: Binding<UUID> {
        .init(get: {
            self.vm.node.id
        }, set: {
            if let node = self.vm.flow.nodes[$0] {
                self.vm.node = node
            }
        })
    }

    var body: some View {
        List {
            
            if self.vm.flow.selection.count > 1 {
                MultiSelectionSectionView(vm: self.vm, items: self.selectedItems, current: self.currentItem)
            }

            TypeSectionView(vm: self.vm)

            self.inputsSectionView
            //                .listRowSeparator(.hidden)
            self.outputsSectionView
        }
        //        .listStyle(.plain)
    }

    var inputsSectionView: some View {
        Section("Inputs") {
            ForEach(self.vm.node.inputs) { input in
                self.inputView(input)
            }
        }
    }

    var outputsSectionView: some View {
        Section("Outputs") {
            ForEach(self.vm.node.outputs) { output in
                OutputRowView(vm: self.vm, output: output)
            }
        }
    }

    @State var value: Double = 0.5
    @ViewBuilder
    func inputView(_ input: FlowNode.Input) -> some View {
        switch input.value.type {
        case .bool:
            BooleanInputControl(input: input, vm: self.vm)
        case .float:
            FloatInputControl(input: input, vm: self.vm)
        case .int:
            IntegerInputControl(input: input, vm: self.vm)
        case .image:
            AssetInputControlView<ImageAssetInputType>(input: input, vm: self.vm)
        case .lut:
            AssetInputControlView<LUTAssetInputType>(input: input, vm: self.vm)
        case .vector2, .vector3, .vector4:
            VectorInputControl(input: input, vm: self.vm)
        case .color4:
            ColorInputControl(input: input, vm: self.vm)
        case .string:
            StringInputControl(input: input, vm: self.vm)
        case .matrix3x3, .matrix5x5, .matrix7x7:
            MatrixInputControl(input: input, vm: self.vm)
        default:
            Text("TODO: \(input.value.type), \(input.semantics, default: "")")
        }
    }

    @ViewBuilder
    func controlView(for input: FlowNode.Input) -> some View {
        switch input.value.type {
        case .bool:
            BooleanInputControl(input: input, vm: self.vm)
        case .float:
            FloatInputControl(input: input, vm: self.vm)
        default:
            Text("")
        }
    }
}

struct OutputRowView: View {
    let vm: InspectorFeatureViewModel
    let output: FlowNode.Output

    @Environment(\.colorScheme) var cs

    var items: [Item] {
        self.vm.flow
            .edges(ofPort: .init(node: self.vm.node.id, port: .output(self.output.index)))
            .compactMap({ self.vm.flow.nodes[$0.to.node] })
            .map({ .init(id: $0.id, name: $0.name) })
    }

    struct Item: Identifiable {
        var id: UUID
        var name: String
    }

    var body: some View {
        LabeledContent {
            if output.connected {
                if self.items.count == 1 {
                    Button {
                        self.vm.flow.select([self.items.first!.id])
                    } label: {
                        Image(systemName: "arrow.right.circle")
                    }
                    .buttonStyle(.borderless)
                    .tint(.secondary)
                } else {
                    Menu {
                        ForEach(self.items) { item in
                            Button(item.name) {
                                self.vm.flow.select([item.id])
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.right.circle")
                    }
                    .buttonStyle(.borderless)
                    .tint(.secondary)
                    .compositingGroup()
                }
            } else {
                Image(systemName: "circle.dotted")
            }
        } label: {
            HStack(alignment: .lastTextBaseline) {
                Text(output.label)
                Text(output.type.displayName)
                    .font(.caption.smallCaps())
                    .bold()
                    .foregroundStyle(.secondary)
                    .padding(4)
                    .background(Color(Color(white: cs == .dark ? 0.1 : 0.95)))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct NodeHeaderView: View {

    let node: FlowNode
    let vm: InspectorFeatureViewModel

    var lockIcon: String {
        self.vm.isLocked ? "lock" : "lock.open"
    }

    var name: Binding<String> {
        .init(
            get: {
                self.vm.node.name
            },
            set: { newValue in
                self.vm.node.name = newValue
            }
        )
    }

    var body: some View {
        HStack {
            HStack {
                Image(systemName: node.kind.icon)
                TextField("", text: self.name)
                    .onSubmit {
                        self.vm.submit(.name, registerUndo: true)
                    }
                    .textFieldStyle(kind: .plain)
                    .font(.headline)
            }

            Spacer()
            Button {
                self.vm.toggleLocked()
            } label: {
                Image(systemName: self.lockIcon)
            }
            .buttonStyle(.plain)

            InspectorNodeMenuButton(node: self.node, vm: self.vm)
        }
    }
}

extension InspectorFeatureView {
    public struct Preview: View {

        @State var show: Bool = true
        @State var flow: SharedModels.Flow
        @State var coordinator: GlobalCoordinator
        @State var assetStore: MockAssetStore

        public init() {
            let flow = Flow()
            //            let node = FlowNode(kind: .valueNode(.bool))
            var nodes = [
                .coreImageFilterNode(.halftoneEffect(.CIDotScreen)),
                NodeKind.coreImageCustomNode(.generator(.blurredRoundedRectangleGeneratorNode)),
                .valueNode(.bool),
            ].map({ FlowNode(kind: $0) })
            nodes[0].inputs[2].connected = true
            for n in nodes {
                flow.addNode(n, at: .zero)
            }
            //            flow.addNode(node, at: .zero)
            flow.selection = [nodes[0].id]
            self._flow = .init(wrappedValue: flow)
            self._coordinator = .init(wrappedValue: .init(flow: flow))
            //            self_.coordinator = .init(MockGlobalCoordinatorService(flow: flow))
            self._assetStore = .init(wrappedValue: .init())
        }

        public init(nodes: [FlowNode], selected: Int? = nil) {
            let flow = Flow()
            for n in nodes {
                flow.addNode(n, at: .zero)
            }

            if let index = selected, nodes.indices.contains(index) {
                flow.selection = [nodes[index].id]
            } else if nodes.first != nil {
                flow.selection = [nodes[0].id]
            }
            self._flow = .init(wrappedValue: flow)
            self._coordinator = .init(wrappedValue: .init(flow: flow))
            self._assetStore = .init(wrappedValue: .init())
        }

        var selection: Binding<UUID?> {
            .init(
                get: {
                    self.flow.selection.first
                },
                set: { newValue in
                    if let newValue {
                        self.flow.selection = [newValue]
                    }
                }
            )
        }

        public var body: some View {
            NavigationStack {
                ZStack {
                    Colors.canvasBackground.color

                    Picker("", selection: self.selection) {
                        ForEach(Array(self.flow.nodes.values), id: \.id) { node in
                            Text("\(node.name)").tag(node.id)
                        }
                    }
                }
                .ignoresSafeArea()
                .inspectorFeatureViewBar(
                    self.$show,
                    flow: self.flow,
                    assetStore: self.assetStore,
                    coordinator: self.coordinator
                )
                .toolbar {
                    ToolbarItem {
                        Button {
                            print("!!!!!!!!!!!")
                            self.show.toggle()
                        } label: {
                            Image(systemName: "sidebar.right")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InspectorFeatureView.Preview()
}

#endif

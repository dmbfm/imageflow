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

    public init(flow: SharedModels.Flow, coordinator: GlobalCoordinator) {
        self._vm = .init(wrappedValue: .init(flow: flow, coordinator: coordinator, undoManager: nil))
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
                    NodeHeaderView(node: self.vm.node)
                        .padding(.horizontal, 28)
                        .padding(.top, 28)
                }
                .clipped()
        }
    }
}

struct NodeFormView: View {

    let vm: InspectorFeatureViewModel
    @Environment(\.colorScheme) var cs

    var body: some View {
        List {
            self.typeSectionView
            self.inputsSectionView
            //                .listRowSeparator(.hidden)
            self.outputsSectionView
        }
        //        .listStyle(.plain)
    }

    var typeSectionView: some View {
        LabeledContent("Type") {
            Text(self.vm.node.kind.displayName)
        }
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
                self.outputView(output)
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

    func outputView(_ output: FlowNode.Output) -> some View {
        LabeledContent {
            if output.connected {
                Button {
                } label: {
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(.borderless)
                .tint(.secondary)
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

    var body: some View {
        HStack {
            HStack {
                Image(systemName: node.kind.icon)
                Text(node.name)
                    .font(.headline)
            }

            Spacer()
            Button {
            } label: {
                Image(systemName: "lock")
            }
            Menu {
                Button("Delete") {}
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

extension InspectorFeatureView {
    public struct Preview: View {

        @State var show: Bool = true
        @State var flow: SharedModels.Flow
        @State var coordinator: GlobalCoordinator

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
            self.flow = flow
            self.coordinator = .init(MockGlobalCoordinatorService(flow: flow))
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
            self.flow = flow
            self.coordinator = .init(MockGlobalCoordinatorService(flow: flow))

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
                .inspectorFeatureViewBar(self.$show, flow: self.flow, coordinator: self.coordinator)
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

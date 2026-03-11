import SwiftUI
import Backend
import InspectorFeatureShared
import SharedModels
import SharedMocking
import Helpers
import Design

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
            ContentUnavailableView("Node Inspector", systemImage: "list.bullet.rectangle.portrait.fill", description: Text("Select a node to inspect it"))
        }
    }
    
    @ViewBuilder
    var contentNodeView: some View {
        VStack {
            // TEMP
            
            Form {
                LabeledContent("Type") {
                    Text(self.vm.node.kind.displayName)
                }
                
                Section("Inputs") {
                    ForEach(self.vm.node.inputs) { input in
                        LabeledContent {
                            Toggle("", isOn: .constant(true))
                        } label: {
                            HStack {
                                Text(input.label)
                                if input.connected {
                                    Button {
                                    } label: {
                                        Image(systemName: "arrow.right.circle")
                                    }
                                    .buttonStyle(.borderless)
                                    .tint(.secondary)
                                    .frame(width: 20)
                                } else {
                                    HStack {}.frame(width: 20)
                                }
                            }
                        }
                    }
                }
                
                Section("Outputs") {
                    ForEach(self.vm.node.outputs) { output in
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
//                                    .font(.)
                                    .font(.caption.smallCaps())
//                                    .fontDesign(.rounded)
                                    .bold()
                                    .foregroundStyle(.secondary)
                                    .padding(4)
                                    .background(Color(Color(white: cs == .dark ? 0.1 : 0.95)))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
            .safeAreaBar(edge: .top) {
                
                NodeHeaderView(node: self.vm.node)
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
//                Text("NODE")
//                    .font(.title)
//                    .padding()
            }
            .clipped()
//            .border(.gray)
            
            // END TEMP
        }
//        .padding(.horizontal, 28)
//        .padding(.top, 28)
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
//            .foregroundStyle(.secondary)
//            .bold()
            
            Spacer()
            Button {} label: {
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
            var nodes = [NodeKind.coreImageCustomNode(.generator(.blurredRoundedRectangleGeneratorNode)),
                         .valueNode(.bool),
            ].map({ FlowNode(kind: $0)})
            nodes[0].inputs[2].connected = true
            for n in nodes {
                flow.addNode(n, at: .zero)
            }
//            flow.addNode(node, at: .zero)
            flow.selection = [nodes[0].id]
            self.flow = flow
            self.coordinator = .init(MockGlobalCoordinatorService(flow: flow))
        }
        
        public var body: some View {
            NavigationStack {
                ZStack {
                    Colors.canvasBackground.color
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

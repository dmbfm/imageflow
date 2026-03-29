import InspectorFeatureShared
import SharedModels
import SwiftUI
import Values

struct DebugBlockView: View {

    let vm: InspectorFeatureViewModel

    var nodes: [FlowNode] {
        Array(self.vm.flow.nodes.values.sorted(by: { $0.name < $1.name }))
    }

    var assets: [Asset] {
        Array(self.vm.assetStore.assets.values)
    }

    var generatedLocations: [OutputPortLocation] {
        self.vm.assetStore.generatedImageLocations
    }

    let maxWidth = 160.0

    var body: some View {
        InspectorBlock("Debug") {
            Form {
                LabeledContent {

                } label: {
                    Text("Flow Graph")
                        .bold()
                }

                LabeledContent {
                    Text("\(self.vm.flow.nodes.count)")
                } label: {
                    InspectorPropertyLabel(label: "Node Count")
                }
                LabeledContent {
                    Text("\(self.vm.flow.edges.count)")
                } label: {
                    InspectorPropertyLabel(label: "Edge Count")
                }
                ForEach(self.nodes, id: \.id) { node in
                    LabeledContent {
                        Text("\(node.id)")
                            .lineLimit(1)
                            .frame(maxWidth: maxWidth)
                            .help("\(node.id)")
                    } label: {
                        Text("\(node.name)")
                    }
                    ForEach(node.inputs, id: \.index) { input in
                        LabeledContent {
                            Text("\(input.value, default: "-")")
                                .lineLimit(1)
                                .frame(maxWidth: maxWidth)
                                .help("\(input.value, default: "-")")
                        } label: {
                            InspectorPropertyLabel(label: "\(node.name)[\(input.index)]")
                        }
                    }
                }

                LabeledContent {
                } label: {
                    Text("Assets")
                        .bold()
                }

                ForEach(self.assets) { asset in
                    LabeledContent {
                        Text("\(asset.kind, default: "nil")")
                            .lineLimit(1)
                            .frame(maxWidth: maxWidth)
                            .help("\(asset.kind, default: "nil")")
                    } label: {
                        Text("kind[\(asset.id.uuidString)]")
                            .lineLimit(1)
                            .frame(maxWidth: maxWidth)
                            .help("kind[\(asset.id.uuidString)]")
                    }
                    LabeledContent {
                        Text("\(asset.state, default: "nil")")
                            .lineLimit(1)
                            .frame(maxWidth: maxWidth)
                            .help("\(asset.state, default: "nil")")
                    } label: {
                        Text("state[\(asset.id.uuidString)]")
                            .lineLimit(1)
                            .frame(maxWidth: maxWidth)
                            .help("state[\(asset.id.uuidString)]")
                    }
                }

                ForEach(self.generatedLocations, id: \.self) { loc in
                    LabeledContent {
                        Text("\(loc.index)")
                    } label: {
                        Text("\(loc.node)")
                            .lineLimit(1)
                            .frame(maxWidth: maxWidth)
                            .help("\(loc.node)")
                    }
                }
            }
        }
    }
}

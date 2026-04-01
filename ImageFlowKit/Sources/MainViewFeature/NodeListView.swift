import SharedModels
import SwiftUI
import Backend

struct NodeListView: View {

    let flow: SharedModels::Flow
    
    var nodes: [Item] {
        self.flow.nodes.values.map({ node in
                .init(id: node.id,name: node.name, kind: node.kind)
        })
        .sorted(by: { $0.name < $1.name })
    }
    
    struct Item: Identifiable {
        var id: UUID
        var name: String
        var kind: NodeKind
    }
    
    var selection: Binding<Set<UUID>> {
        .init(get: {
            self.flow.selection
        }, set: {
            self.flow.selection = $0
        })
    }
    
    var body: some View {
        if nodes.isEmpty {
            ContentUnavailableView("No nodes created!", systemImage: "list.bullet.rectangle.portrait.fill")
        } else {
            List(selection: self.selection) {
                Section("Nodes") {
                    ForEach(self.nodes) { item in
                        let isSelected = self.selection.wrappedValue.contains(item.id)
                        HStack(alignment: .center) {
                            Image(systemName: item.kind.icon)
                                .padding(.bottom, 10)
#if os(iOS)
                                .foregroundStyle( isSelected ? .white : item.kind.frontendNodeColor.color)
#endif
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text(item.kind.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tag(item.id)
                    }
                }
            }
            #if os(macOS)
            .listStyle(.sidebar)
            #else
            .listStyle(.plain)
            #endif
        }
    }
}

#Preview {
    @Previewable @State var show: Bool = true
    let flow: SharedModels::Flow = {
        let flow = Flow()

        flow.addNode(.init(kind: .valueNode(.float)), at: .zero)
        flow.addNode(.init(kind: .valueNode(.int)), at: .zero)
        flow.addNode(.init(kind: .valueNode(.bool), name: "Some very very extremely long name!!!"), at: .zero)
         flow.addNode(.init(kind: .valueNode(.float)), at: .zero)
        flow.addNode(.init(kind: .valueNode(.int)), at: .zero)
        flow.addNode(.init(kind: .valueNode(.bool)), at: .zero)
         flow.addNode(.init(kind: .valueNode(.float)), at: .zero)
        flow.addNode(.init(kind: .valueNode(.int)), at: .zero)
        flow.addNode(.init(kind: .valueNode(.bool)), at: .zero)
        
        return flow
    }()
    
    HStack {
        
        Button("Toggle") {
            show = true
        }
        .popover(isPresented: $show, arrowEdge: .top) {
            NodeListView(flow: flow)
                .frame(width: 250, height: 400)
        }
    }
}

import Logging
import SharedModels
import SwiftUI

struct NodePaletteListView: View {

    let focusBinding: FocusState<Focus?>.Binding
    let port: TypedPortLocation?
    @State var searchText: String = ""

    var onTapItem: ((NodePaletteItem) -> ())?

    var categories: [NodePaletteCategory] {
        if let port = self.port {
            NodePaletteService.shared.categories(
                connectingToType: port.type,
                direction: port.direction,
                searchText: self.searchText
            )
        } else {
            NodePaletteService.shared.categories(searchText: self.searchText)
        }
    }

    @State var expanded: [NodePaletteCategoryName: Bool] = [:]

    func expandedBinding(_ name: NodePaletteCategoryName) -> Binding<Bool> {
        .init(
            get: {
                expanded[name, default: true]
            },
            set: {
                expanded[name, default: true] = $0
            }
        )
    }

    func onTapItemHandler(_ item: NodePaletteItem) {
        self.onTapItem?(item)
    }

    var body: some View {
        List {
            ForEach(categories) { cat in
                Section("\(cat.name.rawValue)", isExpanded: self.expandedBinding(cat.name)) {
                    ForEach(cat.items) { item in
                        HStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .foregroundStyle(item.nodeKind.frontendNodeColor.color)
                            //                                .resizable()
                            //                                .aspectRatio(contentMode: .fit)
                            //                                .frame(width: 12, height: 12)
                            //                                .bold()

                            Text(item.displayName)
                            Spacer()
                        }
                        .contentShape(.capsule)
                        .onTapGesture {
                            self.onTapItemHandler(item)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: self.$searchText)
        .searchFocused(self.focusBinding, equals: .sidebarSearch)
        .onChange(of: self.searchText) {
            self.expanded = [:]
        }
    }
}

import NodePaletteService
import SwiftUI

public struct SidebarFeatureView: View {

    public init() {}

    @State private var hoveredItem: NodePaletteItem? = nil
    @State private var searchText: String = ""
    @State private var expandedSections: [NodePaletteCategoryName:Bool] = [:]
    
    func isExpandedBinding(_ name: NodePaletteCategoryName) -> Binding<Bool> {
        .init(get: {
            self.expandedSections[name, default: true]
        }, set: { newValue in
            self.expandedSections[name] = newValue
        })
    }
    
    var categories: [NodePaletteCategory] {
        NodePaletteService.categories(searchText: self.searchText)
    }

    public var body: some View {
        List {
            ForEach(self.categories) { cat in
                Section(cat.name.rawValue, isExpanded: self.isExpandedBinding(cat.name)) {
                    VStack(spacing: 0) {
                        ForEach(cat.items) { item in
                            HStack {
                                ItemView(item: item)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                            .frame(height: 28)
                            .contentShape(Rectangle())
                            .background {
                                Color.accentColor
                                    .opacity(self.hoveredItem == item ? 0.25 : 0.0)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
//                            .border(.red, width: self.hoveredItem == item ? 1.0 : 0.0)
                            .onHover { hover in
                                self.hoveredItem = hover ? item : nil
                            }
                        }
                    }
                }
            }
        }
        .searchable(text: self.$searchText, placement: .sidebar, prompt: "Search nodes...")
        .onChange(of: self.searchText) { self.expandedSections = [:] }
    }
}

struct ItemView: View {
    let item: NodePaletteItem

    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundStyle(item.nodeKind.frontendNodeColor.color)
            Text(item.displayName)
        }
    }
}

#Preview {
        SidebarFeatureView()
            .listStyle(.sidebar)
}

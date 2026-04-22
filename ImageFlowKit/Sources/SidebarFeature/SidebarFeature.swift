import Backend
import SharedModels
import SwiftUI

public struct SidebarFeatureView: View {

    let focusBinding: FocusState<Focus?>.Binding
    let onDoubleClickItem: ((NodePaletteItem) -> ())?

    @State private var hoveredItem: NodePaletteItem? = nil
    @State private var searchText: String = ""
    @State private var expandedSections: [NodePaletteCategoryName: Bool] = [:]

    public init(_ focusState: FocusState<Focus?>.Binding, _ onDoubleClickItem: ((NodePaletteItem) -> ())? = nil) {
        self.focusBinding = focusState
        self.onDoubleClickItem = onDoubleClickItem
    }

    func isExpandedBinding(_ name: NodePaletteCategoryName) -> Binding<Bool> {
        .init(
            get: {
                self.expandedSections[name, default: true]
            },
            set: { newValue in
                self.expandedSections[name] = newValue
            }
        )
    }

    var categories: [NodePaletteCategory] {
        NodePaletteService.shared.categories(searchText: self.searchText)
    }

    func nodeKindDragItem(_ item: NodePaletteItem) -> NodeKindDragItem {
        .init(kind: item.nodeKind)
    }

    func nodeKindDragItemProvider(_ item: NodePaletteItem) -> NSItemProvider {
        .init(object: NodeKindDragItem(kind: item.nodeKind))
    }

    func itemDoubleTapHandler(_ item: NodePaletteItem) {
        self.onDoubleClickItem?(item)
    }

    public var body: some View {
        List {
            ForEach(self.categories) { self.categoryView($0) }
        }
        .searchable(text: self.$searchText, placement: .sidebar, prompt: "Search nodes...")
        .searchFocused(self.focusBinding, equals: .sidebarSearch)
        .onChange(of: self.searchText) { self.expandedSections = [:] }
    }

    func categoryView(_ cat: NodePaletteCategory) -> some View {
        Section(cat.name.rawValue, isExpanded: self.isExpandedBinding(cat.name)) {
            VStack(spacing: 0) {
                ForEach(cat.items) { self.itemView($0) }
            }
        }
    }

    func itemView(_ item: NodePaletteItem) -> some View {
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
        .onDrag({ self.nodeKindDragItemProvider(item) })
        .onHover { hover in
            self.hoveredItem = hover ? item : nil
        }
        .onTapGesture(count: 2) { self.itemDoubleTapHandler(item) }
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
    @Previewable @FocusState var focus: Focus?
    SidebarFeatureView($focus)
        .listStyle(.sidebar)
}

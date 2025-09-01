import Logging
import Models
import NodePaletteService
import SwiftUI

struct NodePaletteListView: View {

    @State var searchText: String = ""

    var onTapItem: ((NodePaletteItem) -> ())?

    var categories: [NodePaletteCategory] {
        if searchText.isEmpty {
            return NodePaletteService.shared.categories
        } else {
            return NodePaletteService.shared.categories.map { cat in
                var r = cat
                r.items = cat.items.filter { item in
                    item.displayName.contains(searchText)
                }
                return r
            }.filter({ !$0.items.isEmpty })
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
        log("Tapped item: \(item.displayName)")
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
        .onChange(of: self.searchText) {
            self.expanded = [:]
        }
    }
}

struct NodePaletteSheetView: View {
    var onTapItem: ((NodePaletteItem) -> ())?
    var topPadding: CGFloat {
        if #available(iOS 26, *) {
            -50
        } else {
            0
        }
    }
    var body: some View {
        NavigationStack {
            NodePaletteListView() { self.onTapItem?($0) }
                .navigationBarBackButtonHidden()
                .navigationTitle("Add Node")
                #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
                #endif
        }
        .padding(.top, self.topPadding)
    }
}

#Preview {
    ZStack {
        Color.clear
        Text("Preview!")
            .font(.largeTitle)
    }
    .sheet(isPresented: .constant(true)) {
        NodePaletteSheetView()
        //            .presentationDetents([.medium, .large])
    }
}

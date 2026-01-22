#if os(macOS)

import SwiftUI
import SharedModels
import Helpers

public extension View {
    func nodePaletteSearchPopover(
        isPresentedAt: Binding<CGPoint?>,
        focus: FocusState<Focus?>.Binding,
        onPickItem: @escaping (NodePaletteItem, CGPoint?) -> (),
    ) -> some View {
        self.popover(isPresentedAt: isPresentedAt, positioning: .cursor, size: NodePaletteSearchPopoverView.size) {
            NodePaletteSearchPopoverView(isPresentedAt, focus: focus, onPickItem: onPickItem) {
                isPresentedAt.wrappedValue = nil
            }
        }
    }
}

struct NodePaletteSearchPopoverView: View {

    @State var text: String = ""
    @State var selectedItem: NodePaletteItem?

    @Binding var _position: CGPoint?

    @Environment(\.colorScheme) var cs

    var focus: FocusState<Focus?>.Binding
    var onPickItem: (NodePaletteItem, CGPoint?) -> ()
    var dismiss: () -> ()

    let palette = NodePaletteService.shared

    static let size: CGSize = .init(width: 400, height: 200)

    init(
        _ position: Binding<CGPoint?>,
        focus: FocusState<Focus?>.Binding,
        onPickItem: @escaping (NodePaletteItem, CGPoint?) -> (),
        dismiss: @escaping () -> ()
    ) {
        self.__position = position
        self.focus = focus
        self.onPickItem = onPickItem
        self.dismiss = dismiss
    }

    var items: [NodePaletteItem] {
        palette.items(searchText: self.text)
    }

    var searchView: some View {
        TextField("", text: self.$text)
            .font(.system(size: 12))
            .focused(self.focus, equals: .nodeSearch)
            .textFieldStyle(.plain)
            .padding(2)
            .background { self.cs == .light ? Color.white : Color.black }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(1)
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.tertiary)
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 8)
    }

    func selectNext() {
        guard let selected = self.selectedItem, self.items.count > 1, let index = self.items.firstIndex(of: selected)
        else { return }

        self.selectedItem = self.items[(index + 1) % self.items.count]
    }

    func selectPrev() {
        guard let selected = self.selectedItem, self.items.count > 1, let index = self.items.firstIndex(of: selected)
        else { return }

        self.selectedItem = self.items[(index + self.items.count - 1) % self.items.count]
    }

    func itemView(_ item: NodePaletteItem) -> some View {
        HStack(spacing: 4) {
            Text(item.categoryName.rawValue)
                .foregroundStyle(.tertiary)
            Image(systemName: "chevron.compact.right")
                .foregroundStyle(.tertiary)
            Image(systemName: item.icon)
            Text(item.displayName)
            Spacer()
        }
        .font(.caption)
        .frame(maxWidth: .infinity)
        .padding(.leading, 16)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .background {
            if self.selectedItem == item {
                Color.accentColor.opacity(0.5)
            } else {
                Color.clear
            }
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(_):
                if self.selectedItem != item {
                    self.selectedItem = item
                }
            default: break
            }
        }
        .onTapGesture {
            self.onPickItem(item, self._position)
            self.dismiss()
        }
    }

    var listView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(self.items) { item in
                    self.itemView(item)
                        .tag(item)
                }
            }
        }
        .scrollPosition(id: self.$selectedItem)
    }

    var body: some View {
        VStack(spacing: 0) {
            self.searchView
            self.listView
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .onKeyPress(
            phases: [.down, .repeat],
            action: { press in
                if (press.key == "n" && press.modifiers.contains(.control)) || press.key == .downArrow {
                    self.selectNext()
                    return .handled
                } else if press.key == "p" && press.modifiers.contains(.control) || press.key == .upArrow {
                    self.selectPrev()
                    return .handled
                } else if press.key == .return {
                    if let item = self.selectedItem {
                        self.dismiss()
                        self.onPickItem(item, self._position)
                    }
                    return .handled
                }

                return .ignored
            }
        )
        .onChange(
            of: self.text,
            initial: true,
            {
                if self.selectedItem == nil || !self.items.contains(self.selectedItem!) {
                    self.selectedItem = self.items.first
                }
            }
        )
    }
}

#endif

#if os(macOS)

import SwiftUI
import AppKit
import SharedModels
import Helpers

public struct NodePaletteSearchPopoverView: View {

    @State var text: String = ""
    @State var selectedItem: NodePaletteItem?

    var _position: CGPoint?

    @Environment(\.colorScheme) var cs

    var focus: FocusState<Focus?>.Binding
    var onPickItem: (NodePaletteItem, CGPoint?) -> ()
    var dismiss: () -> ()

    let palette = NodePaletteService.shared

    static let size: CGSize = .init(width: 400, height: 200)

    public init(
        _ position: CGPoint?,
        focus: FocusState<Focus?>.Binding,
        onPickItem: @escaping (NodePaletteItem, CGPoint?) -> (),
        dismiss: @escaping () -> ()
    ) {
        self._position = position
        self.focus = focus
        self.onPickItem = onPickItem
        self.dismiss = dismiss
    }

    var items: [NodePaletteItem] {
        palette.items(searchText: self.text.trimmingCharacters(in: .whitespaces))
    }

    var searchView: some View {
        _TextField(text: self.$text)
            .font(.system(size: 12))
            .focused(self.focus, equals: .nodeSearch)
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

    public var body: some View {
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

struct _TextField: NSViewRepresentable {

    @Binding var text: String
    var font: NSFont? = nil

    func makeNSView(context: Context) -> NSTextField {
        let view = NSTextField()
        view.focusRingType = .none
        view.font = self.font
        view.text = self.text
        view.delegate = context.coordinator
        view.maximumNumberOfLines = 1
        view.isAutomaticTextCompletionEnabled = false
        view.allowsWritingTools = false
        context.coordinator.text = self.$text
        return view
    }

    func updateNSView(_ view: NSTextField, context: Context) {
        view.text = self.text
        context.coordinator.text = self.$text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, NSTextFieldDelegate {

        var text: Binding<String>?

        func controlTextDidChange(_ obj: Notification) {
            if let text = self.text, let object = obj.object, let textField = object as? NSTextField {
                text.wrappedValue = textField.text
            }
        }

        func controlTextDidBeginEditing(_ obj: Notification) {

        }

        func controlTextDidEndEditing(_ obj: Notification) {

        }
    }
}
#endif

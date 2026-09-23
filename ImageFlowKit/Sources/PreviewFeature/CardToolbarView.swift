import SwiftUI

enum CardToolbarItemName {
    case lock
    case dockDown
    case dockUp
    case window
    case copy
    case export
}

struct CardToolbarView: View {

    var handler: ((CardToolbarItemName) -> ())?
    var visible: Bool
    var locked: Bool = false

    func icon(_ name: CardToolbarItemName) -> String {
        switch name {
        case .copy:
            return .systemIconMenuCopy
        case .dockDown:
            return .systemIconDockDown
        case .dockUp:
            return .systemIconDockUp
        case .export:
            return .systemIconSave
        case .lock:
            return self.locked ? .systemIconLock : .systemIconLockOpen
        case .window:
            return .systemIconWindowPreview
        }
    }

    func makeButton(_ name: CardToolbarItemName, glassID: String) -> some View {
        Button {
            self.handler?(name)
        } label: {
            Image(systemName: self.icon(name))
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        GlassEffectContainer(spacing: 0) {
            if self.visible {
                ZStack(alignment: .top) {
                    Color.clear
                    HStack(spacing: 0) {
                        self.makeButton(.lock, glassID: "left")
                            .help("Lock Preview")
                            .glassEffect(.regular.interactive(), in: .capsule)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 22)

                    HStack(spacing: 0) {
                        Spacer(minLength: 22)

                        HStack(spacing: 0) {
                            self.makeButton(.dockDown, glassID: "middle")
                                .help("Dock to Bottom")
                            self.makeButton(.dockUp, glassID: "middle")
                                .help("Dock to Top")
                            self.makeButton(.window, glassID: "middle")
                                .help("Open in Window")
                        }
                        .glassEffect(.regular.interactive(), in: .capsule)

                        Spacer(minLength: 48)
                    }
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 0) {
                        Spacer()

                        HStack(spacing: 0) {
                            self.makeButton(.copy, glassID: "right")
                                .help("Copy Image")
                            self.makeButton(.export, glassID: "right")
                                .help("Export Image")
                        }
                        .glassEffect(.regular.interactive(), in: .capsule)
                    }
                    .frame(maxWidth: .infinity)
                }
                .controlSize(.small)
                .padding(.top, 8)
                .padding(.horizontal, 8)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: self.visible)
    }
}

#Preview {
    @Previewable @State var visible = true
    VStack {
        ZStack {
            Color.teal
            CardToolbarView(visible: visible)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(width: 250, height: 300)
        .padding()

        Toggle("Visible", isOn: $visible)
            .padding()
    }
}

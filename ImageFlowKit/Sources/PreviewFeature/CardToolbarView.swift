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

    @Namespace var ns

    let buttonWidth: CGFloat = 4.0
    let buttonHeight: CGFloat = 16.0

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
                .frame(width: buttonWidth, height: buttonHeight)

        }
        .buttonStyle(.glass)
        .glassEffectUnion(id: glassID, namespace: ns)
    }

    var body: some View {
        GlassEffectContainer(spacing: 8) {
            if self.visible {
                ZStack(alignment: .top) {
                    Color.clear
                    HStack(spacing: 0) {
                        self.makeButton(.lock, glassID: "left")
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 22)

                    HStack(spacing: 0) {
                        Spacer(minLength: 22)

                        self.makeButton(.dockDown, glassID: "middle")
                        self.makeButton(.dockUp, glassID: "middle")
                        self.makeButton(.window, glassID: "middle")

                        Spacer(minLength: 48)
                    }
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 0) {
                        Spacer()

                        self.makeButton(.copy, glassID: "right")
                        self.makeButton(.export, glassID: "right")
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

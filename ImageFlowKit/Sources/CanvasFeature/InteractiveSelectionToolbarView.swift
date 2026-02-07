import SwiftUI

struct InteractiveSelectionToolbarView: View {

    @Environment(\.colorScheme) var cs

    enum Action {
        case selectNone
        case selectAll
        case done
    }

    var shadowColor: Color {
        switch cs {
        case .light: Color(white: 0.0, opacity: 0.12)
        case .dark: Color(white: 1.0, opacity: 1)
        @unknown default: Color(white: 0.0, opacity: 0.12)
        }
    }

    var visible: Bool = true
    var onAction: ((Action) -> ())?

    var body: some View {
        GlassEffectContainer {
            HStack {
                if self.visible {
                    HStack {
                        Text("Drag across the screen to select nodes. Tap a node to select or deselect it.")
                            .frame(maxWidth: 300)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                            .padding(.trailing, 36)

                        Button("Select None") {
                            self.onAction?(.selectNone)
                        }
                        .buttonStyle(.glass)

                        Button("Select All") {
                            self.onAction?(.selectAll)
                        }
                        .buttonStyle(.glass)

                        Button("Done") {
                            self.onAction?(.done)
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.glassProminent)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
                    // .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 36))
                    .glassEffectTransition(.matchedGeometry)
                }
            }
        }
        .animation(.easeIn(duration: 0.25), value: self.visible)
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var cs
    ZStack(alignment: .bottom) {
        //        Color(UIColor(white: 0.95, alpha: 1.0))
        if cs == .dark {
            Color(white: 0.05)
        } else {
            Color(white: 0.95)
        }
        InteractiveSelectionToolbarView()
            .padding(.bottom, 80)
    }
}

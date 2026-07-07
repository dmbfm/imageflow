import Design
import SwiftUI

@Observable
final class StatusBarState {
    var visible: Bool = true
    var text: String = ""

    init(visible: Bool = true, text: String = "") {
        self.visible = visible
        self.text = text
    }
}

struct StatusBarView: View {

    var state: StatusBarState
    @State var size: CGSize = .zero

    var body: some View {
        GlassEffectContainer {
            if self.state.visible {
                HStack {
                    Text(self.state.text)
                        .fixedSize()
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .glassEffect()
                .glassEffectTransition(.materialize)
                .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { self.size = $0 })
            }
        }
        .frame(minWidth: self.size.width, minHeight: self.size.height)
        .animation(.easeInOut(duration: 0.15), value: self.state.visible)
    }
}

#Preview {
    ZStack {
        Colors.canvasBackground.color
        StatusBarView(state: .init(visible: true, text: "⇧ Slower     ⌥ Faster     ⌘ Snap values"))
            .padding(20)
    }
}

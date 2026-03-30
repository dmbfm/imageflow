import Design
import SwiftUI

struct StatusBarState: Equatable {
    var visible: Bool
    var text: String
}

struct StatusBarView: View {

    var state: StatusBarState

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.clear
            GlassEffectContainer {
                if self.state.visible {
                    HStack {
                        Text(self.state.text)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .glassEffect()
                    .glassEffectTransition(.materialize)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Colors.canvasBackground.color
        StatusBarView(state: .init(visible: true, text: "⇧ Slower     ⌥ Faster     ⌘ Snap values"))
            .padding(20)
    }
}

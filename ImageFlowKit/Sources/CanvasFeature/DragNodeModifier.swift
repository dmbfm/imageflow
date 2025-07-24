import SwiftUI
import CommonUtils

struct DragNodeModifier: ViewModifier {

    @Binding var position: CGPoint
    @State var startPos: CGPoint?

    func translate(by t: CGSize) {
        if let startPos = self.startPos {
            self.position = startPos + t.cgPoint
        }
    }

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture().onChanged { value in
                    if self.startPos == nil {
                        self.startPos = self.position
                    }

                    self.translate(by: value.translation)
                }.onEnded { value in
                    self.translate(by: value.translation)
                    self.startPos = nil
                }
            )
    }
}

extension View {
    func dragNode(_ position: Binding<CGPoint>) -> some View {
        self.modifier(DragNodeModifier(position: position))
    }
}

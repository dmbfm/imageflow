import CommonUtils
import SwiftUI

struct DragNodeModifier: ViewModifier {

    @Binding var position: CGPoint
    @State var startPos: CGPoint?
    @Environment(\.undoManager) var undoManager

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
                        self.undoManager?.beginUndoGrouping()
                        self.undoManager?.setActionName("Move Node")
                    }

                    self.translate(by: value.translation)
                }.onEnded { value in
                    self.translate(by: value.translation)
                    self.startPos = nil
                    self.undoManager?.endUndoGrouping()
                }
            )
    }
}

extension View {
    func dragNode(_ position: Binding<CGPoint>) -> some View {
        self.modifier(DragNodeModifier(position: position))
    }
}

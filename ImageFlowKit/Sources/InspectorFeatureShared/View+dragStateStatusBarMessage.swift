import SharedModels
import SwiftUI

extension View {
    public func dragStateStatusBarMessage(
        coordinator: GlobalCoordinator,
        dragState: DragState,
        message: String,
    ) -> some View {
        self.modifier(
            DragStateStatusBarMessageModifier(dragState: dragState, message: message, coordinator: coordinator)
        )
    }
}

struct DragStateStatusBarMessageModifier: ViewModifier {

    var dragState: DragState
    var message: String
    var coordinator: GlobalCoordinator

    func body(content: Content) -> some View {
        content
            .onChange(
                of: self.dragState,
                initial: false,
                {
                    switch self.dragState {
                    case .dragging:
                        self.coordinator.statusBar(self.message)
                    case .notDragging:
                        self.coordinator.statusBar(nil)
                    }
                }
            )
    }
}

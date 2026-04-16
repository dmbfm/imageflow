import SwiftUI
import SharedModels

struct DragStatusMessageModifier: ViewModifier {
    @Binding var isDragging: Bool
    let message: [StatusBarMessageBuilder.Item]
    let coordinator: GlobalCoordinator

    func body(content: Content) -> some View {
        content
            .onChange(
                of: self.isDragging,
                initial: false,
                {
                    if self.isDragging {
                        self.coordinator.statusBar(StatusBarMessageBuilder.build(self.message))
                    } else {
                        self.coordinator.statusBar(nil)
                    }
                }
            )
    }
}

extension View {
    func dragStatusBarMessage(
        _ isDragging: Binding<Bool>,
        message: [StatusBarMessageBuilder.Item],
        coordinator: GlobalCoordinator
    ) -> some View {
        self.modifier(DragStatusMessageModifier(isDragging: isDragging, message: message, coordinator: coordinator))
    }
}

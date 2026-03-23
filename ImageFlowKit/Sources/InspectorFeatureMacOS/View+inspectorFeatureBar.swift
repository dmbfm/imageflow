import InspectorFeatureShared
import SharedModels
import SwiftUI

extension View {
    public func inspectorFeatureViewBar(
        _ isPresented: Binding<Bool>,
        flow: Flow,
        coordinator: GlobalCoordinator,
    ) -> some View {
        self.modifier(
            InspectorFeatureViewBarModifier(isPresented, flow: flow, coordinator: coordinator)
        )
    }
}

public struct InspectorFeatureViewBarModifier: ViewModifier {
    public init(_ isPresented: Binding<Bool>, flow: Flow, coordinator: GlobalCoordinator, ) {
        self._isPresented = isPresented
        self.flow = flow
        self.coordinator = coordinator
    }

    @Binding var isPresented: Bool

    let flow: SharedModels.Flow
    let coordinator: GlobalCoordinator

    public func body(content: Content) -> some View {
        content
            .customSidebar(self.$isPresented) {
                InspectorFeatureView(flow: self.flow, coordinator: self.coordinator)
            }
            .customSidebarRadius(22)
            .customSidebarWidth(.range(range: 200...600, ideal: 350))
            .customSidebarInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 8))
    }
}

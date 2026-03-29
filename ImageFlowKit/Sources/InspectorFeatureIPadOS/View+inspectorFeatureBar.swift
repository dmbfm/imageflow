#if os(iOS)

import SharedModels
import SwiftUI
import InspectorFeatureShared

extension View {
    public func inspectorFeatureViewBar(
        _ isPresented: Binding<Bool>,
        flow: Flow,
        assetStore: any AssetStoreService,
        coordinator: GlobalCoordinator,
    ) -> some View {
        self.modifier(
            InspectorFeatureViewBarModifier(isPresented, flow: flow, assetStore: assetStore, coordinator: coordinator)
        )
    }
}

public struct InspectorFeatureViewBarModifier: ViewModifier {

    public init(
        _ isPresented: Binding<Bool>,
        flow: Flow,
        assetStore: any AssetStoreService,
        coordinator: GlobalCoordinator
    ) {
        self._isPresented = isPresented
        self.flow = flow
        self.coordinator = coordinator
        self.assetStore = assetStore
    }

    @Binding var isPresented: Bool

    let flow: SharedModels.Flow
    let coordinator: GlobalCoordinator
    let assetStore: any AssetStoreService

    public func body(content: Content) -> some View {
        content
            .customSidebar(self.$isPresented) {
                VStack {
                    InspectorFeatureView(flow: self.flow, assetStore: self.assetStore, coordinator: self.coordinator)
                    Spacer()
                }
            }
            .customSidebarWidth(.fixed(340))
            .customSidebarRadius(32)
    }
}

#endif

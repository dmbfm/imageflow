//
//  View+inspectorFeatureBar.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/03/26.
//

import SharedModels
import SwiftUI

extension View {
    public func inspectorFeatureViewBar(
        _ isPresented: Binding<Bool>,
        insets: EdgeInsets? = nil,
        flow: Flow,
        coordinator: GlobalCoordinator,
    ) -> some View {
        self.modifier(
            InspectorFeatureViewBarModifier(isPresented, flow: flow, coordinator: coordinator, insets: insets)
        )
    }
}

public struct InspectorFeatureViewBarModifier: ViewModifier {

    public init(_ isPresented: Binding<Bool>, flow: Flow, coordinator: GlobalCoordinator, insets: EdgeInsets? = nil) {
        self._isPresented = isPresented
        self.flow = flow
        self.coordinator = coordinator
        self.insets = insets ?? .init()
    }

    @Binding var isPresented: Bool

    let flow: SharedModels.Flow
    let coordinator: GlobalCoordinator
    let insets: EdgeInsets

    public func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .trailing) {
                if self.isPresented {
                    VStack {
                        InspectorFeatureView(flow: self.flow, coordinator: self.coordinator)
                        Spacer()
                    }
                    .frame(width: 340)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .padding(.trailing, 24)
                    .safeAreaPadding(self.insets)
//                    .ignoresSafeArea(.keyboard)
                    .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: self.isPresented)
    }
}

// .safeAreaInset(edge: .trailing) {
//    if self.vm.showInspector {
//            VStack {
//                InspectorFeatureView(flow: self.vm.flow, coordinator: self.vm.coordinator)
//                Spacer()
//            }
//            .frame(width: 300)
//            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
//            .padding(.trailing, 12)
//        .transition(.move(edge: .trailing))
//    }
// }

#if os(macOS)

import SwiftUI
import SharedModels
import CanvasFeature

extension MainContentViewMacOS {
    struct DetailView: View {

        let vm: MainContentViewModel
        let focus: FocusState<Focus?>.Binding

        @Environment(\.colorScheme) var cs
        @Environment(\.undoManager) var um

        var body: some View {
            @Bindable var vm = self.vm
            ZStack(alignment: .top) {
                CanvasFeatureView(
                    self.vm.canvas,
                    self.vm.flow,
                    self.vm.assetStore,
                    self.focus,
                    self.vm,
                    action: $vm.canvasAction,
                )
                .onGeometryChange(for: CGPoint.self) { proxy in
                    proxy.frame(in: .local).center
                } action: { newValue in
                    self.vm.canvasCenter = newValue
                }
                .focusable(true, interactions: .edit)
                .focused(self.focus, equals: .global)
                .focusEffectDisabled()
                .onDeleteCommand(perform: self.vm.onDeleteCommand)
                .onKeyPress(.space, action: self.vm.onKeyPressSpace)

                // NOTE: `Color.white.opacity(0.0001)` + backgroundExtensionEffect() creates a blur
                // effect on the toolbar! This does not work if we use `Color.clear` instead.
                Rectangle()
                    .fill(Color.white.opacity(0.0001))
                    .frame(height: 60)
                    .ignoresSafeArea(.all, edges: [.top])
                    .backgroundExtensionEffect()
            }
        }
    }
}

#endif

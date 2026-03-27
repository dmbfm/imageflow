#if os(macOS)

import SwiftUI
import SharedModels
import CanvasFeature
import InspectorFeatureShared

extension MainContentViewMacOS {
    struct DetailView: View {

        let vm: MainContentViewModel
        let focus: FocusState<Focus?>.Binding

        @State var opacity: CGFloat = 0.0

        @Environment(\.colorScheme) var cs
        @Environment(\.undoManager) var um

        func onKeyPressSpace() -> KeyPress.Result {
            if let responder = NSApp.keyWindow?.firstResponder {
                if responder is NSText {
                    return .ignored
                }
            }

            if self.focus.wrappedValue == .global || self.focus.wrappedValue == nil {
                self.vm.coordinator.perform(userAction: .showNodeSearch(typedPortLocation: nil, canvasPosition: nil))
                return .handled
            }

            return .ignored
        }

        var body: some View {
            @Bindable var vm = self.vm
            ZStack(alignment: .top) {
                CanvasFeatureView(
                    self.vm.canvas,
                    self.vm.flow,
                    self.vm.assetStore,
                    self.focus,
                    coordinator: self.vm.coordinator
                )
                .inspectorFeatureViewBar(
                    self.vm.showInspectorSafeBinding,
                    flow: self.vm.flow,
                    coordinator: self.vm.coordinator
                )
                .focusable(true, interactions: .edit)
                .focused(self.focus, equals: .global)
                .focusEffectDisabled()
                .onDeleteCommand(perform: self.vm.onDeleteCommand)
                .onCopyCommand(perform: self.vm.onCopyCommand)
                .onPasteCommand(of: [.flowNode], perform: self.vm.onPasteCommand(_:))
                .onCutCommand(perform: self.vm.onCutCommand)
                .onKeyPress(.space, action: self.onKeyPressSpace)

                // NOTE: `Color.white.opacity(0.0001)` + backgroundExtensionEffect() creates a blur
                // effect on the toolbar! This does not work if we use `Color.clear` instead.
                Rectangle()
                    .fill(Color.white.opacity(self.opacity))
                    .frame(height: 60)
                    .ignoresSafeArea(.all, edges: [.top])
                    .backgroundExtensionEffect()
                    .task {
                        do {
                            try await Task.sleep(for: .seconds(1.0))
                            self.opacity = 0.0001
                        } catch {}
                    }
            }
        }
    }
}

#endif

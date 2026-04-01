#if os(iOS)

import SwiftUI
import SharedModels

extension MainContentViewIPadOS {

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .secondaryAction) {
            Button {
                self.vm.coordinator.perform(userAction: .viewport(.zoomIn))
            } label: {
                Image(systemName: "plus")
            }
            .disabled(self.vm.canvas.viewport.scale >= 1.0)

            Menu {
                Button("Fit Content") {
                    self.vm.coordinator.perform(userAction: .viewport(.zoomToFitContent))
                }
                .disabled(self.vm.flow.nodes.isEmpty)
                Button("Fit Selected") {
                    self.vm.coordinator.perform(userAction: .viewport(.zoomToFitSelection))
                }
                .disabled(self.vm.flow.selection.isEmpty)
                Divider()
                ForEach(self.zoomValues, id: \.self) { value in
                    Button(zoomFormatter.string(for: value) ?? "") {
                        self.vm.coordinator.perform(userAction: .viewport(.setZoom(value)))
                    }
                }
            } label: {
                Text(zoomFormatter.string(for: self.vm.canvas.viewport.scale) ?? "")
            }

            Button {
                self.vm.coordinator.perform(userAction: .viewport(.zoomOut))
            } label: {
                Image(systemName: "minus")
            }
            .disabled(self.vm.canvas.viewport.scale <= 0.1)
        }

        ToolbarItem(placement: .primaryAction) {
            Button { [weak vm = self.vm] in
                vm?.nodePalettePresent()
            } label: {
                Image(systemName: "plus")
            }
            .keyboardShortcut(.init(.space, modifiers: []))
        }

        ToolbarItem(placement: .primaryAction) {
            Button("Node List", systemImage: "list.bullet") {
                self.vm.showNodeListPopover = true
            }
            .popover(
                isPresented: self.$vm.showNodeListPopover,
                arrowEdge: .bottom,
                content: {
                    NodeListView(flow: self.vm.flow)
                        .frame(width: 250, height: 400)
                }
            )
        }

        ToolbarItem(placement: .primaryAction) {
            if let previewState = self.previewState {
                @Bindable var p = previewState

                Menu("Preview", systemImage: "pip") {
                    Picker("Preview", selection: $p.previewPosition) {
                        Label("Top Left", systemImage: "inset.filled.topleft.rectangle")
                            .tag(PreviewPosition.topLeft)
                        Label("Top Right", systemImage: "inset.filled.topright.rectangle")
                            .tag(PreviewPosition.topRight)
                        Label("Bottom Left", systemImage: "inset.filled.bottomleft.rectangle")
                            .tag(PreviewPosition.bottomLeft)
                        Label("Bottom Right", systemImage: "inset.filled.bottomright.rectangle")
                            .tag(PreviewPosition.bottomRight)
                        Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                            .tag(PreviewPosition.topDock)
                        Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                            .tag(PreviewPosition.bottomDock)
                    }
                    .labelsVisibility(.visible)
                }
            } else {
                Button("", systemImage: "xmark") {}
            }
        }

        ToolbarSpacer(.fixed, placement: .primaryAction)

        ToolbarItemGroup(placement: .primaryAction) {
            Button("Undo", systemImage: "arrow.uturn.backward") {
                self.undoManager?.undo()
            }
            .disabled(!self.vm.canUndo)

            Button("Redo", systemImage: "arrow.uturn.forward") {
                self.undoManager?.redo()
            }
            .disabled(!self.vm.canRedo)
        }

        ToolbarSpacer(.fixed, placement: .primaryAction)

        ToolbarItem(placement: .primaryAction) {
            Button("Open Asset Browser", systemImage: "photo.stack") {
                self.vm.openAssetBrowser()
            }
            // Button {
            //     self.vm.openAssetBrowser()
            // } label: {
            //     Image(systemName: "square.and.arrow.down.fill")
            // }
        }

        ToolbarSpacer(.fixed, placement: .primaryAction)

        ToolbarItem(id: "toggle-inspector-v2", placement: .primaryAction) {
            Button("Toggle Inspector", systemImage: "sidebar.right") {
                self.vm.showInspector.toggle()
            }
        }
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

#endif

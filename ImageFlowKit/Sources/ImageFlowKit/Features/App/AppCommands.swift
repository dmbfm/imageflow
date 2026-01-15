import Helpers
import SwiftUI

struct PreviewFeatureCommands: Commands {

    @ActiveViewObject(PreviewFeatureState.self) var previewState
    @ActiveViewObject(DockedPreviewMenuActionCoordinator.self) var previewCoordinator

    #if os(macOS)
    @FocusedValue(WindowPreviewViewModel.self) var windowPreviewViewModel
    #endif

    var body: some Commands {

        CommandGroup(after: .sidebar) {

            Section {
                if let previewState = self.previewState {
                    Menu("Preview Position") {
                        Picker("Floating", selection: previewState.previewPositionSafeBinding) {
                            Label("Top Left", systemImage: "inset.filled.topleft.rectangle")
                                .tag(PreviewPosition.topLeft)
                            Label("Top Right", systemImage: "inset.filled.topright.rectangle")
                                .tag(PreviewPosition.topRight)
                            Label("Bottom Left", systemImage: "inset.filled.bottomleft.rectangle")
                                .tag(PreviewPosition.bottomLeft)
                            Label("Bottom Right", systemImage: "inset.filled.bottomright.rectangle")
                                .tag(PreviewPosition.bottomRight)
                        }
                        .labelsVisibility(.visible)
                        .pickerStyle(.inline)

                        Picker("Docked", selection: previewState.previewPositionSafeBinding) {
                            Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                                .tag(PreviewPosition.bottomDock)
                            Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                                .tag(PreviewPosition.topDock)
                        }
                        .labelsVisibility(.visible)
                        .pickerStyle(.inline)
                    }
                }

                #if os(macOS)
                if let vm = self.windowPreviewViewModel {
                    Menu {
                        Button { [weak vm] in
                            vm?.action = .zoomIn(animate: true)
                        } label: {
                            LabeledContent("Zoom In") {
                                Image(systemName: "plus.magnifyingglass")
                            }
                        }

                        Button { [weak vm] in
                            vm?.action = .zoomOut(animate: true)
                        } label: {
                            LabeledContent("Zoom Out") {
                                Image(systemName: "minus.magnifyingglass")
                            }
                        }

                        Button { [weak vm] in
                            vm?.action = .actualSize(animate: true)
                        } label: {
                            LabeledContent("Actual Size") {
                                Image(systemName: "1.magnifyingglass")
                            }
                        }

                        Button { [weak vm] in
                            vm?.action = .zoomToFit(animate: true)
                        } label: {
                            LabeledContent("Zoom To Fit") {
                                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            }
                        }

                        Divider()

                        Toggle(isOn: vm.pinnedBinding) {
                            LabeledContent("Always On Top") {
                                Image(systemName: "pin")
                            }
                        }

                    } label: {
                        LabeledContent("Preview Window") {
                            // Image(systemName: "macwindow")
                        }
                    }
                }
                #endif

                #if os(macOS)
                let isWindowPreviewFocused = self.windowPreviewViewModel != nil
                #else
                let isWindowPreviewFocused = false
                #endif

                if let vm = self.previewCoordinator, !isWindowPreviewFocused {
                    Menu {
                        Button { [weak vm] in
                            vm?.action = .zoomIn
                        } label: {
                            LabeledContent("Zoom In") {
                                Image(systemName: "plus.magnifyingglass")
                            }
                        }

                        Button { [weak vm] in
                            vm?.action = .zoomOut
                        } label: {
                            LabeledContent("Zoom Out") {
                                Image(systemName: "minus.magnifyingglass")
                            }
                        }
                        Button { [weak vm] in
                            vm?.action = .actualSize
                        } label: {
                            LabeledContent("Actual Size") {
                                Image(systemName: "1.magnifyingglass")
                            }
                        }

                        Button { [weak vm] in
                            vm?.action = .zoomToFit
                        } label: {
                            LabeledContent("Zoom To Fit") {
                                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            }
                        }
                    } label: {
                        LabeledContent("Docked Preview") {
                        }
                    }
                }

                #if os(macOS)
                if let previewState = self.previewState, !isWindowPreviewFocused {
                    Button { [weak previewState] in
                        if let loc = previewState?.location {
                            previewState?.openPreviewWindow(loc)
                        }
                    } label: {
                        LabeledContent("Open Preview Window") {
                            Image(systemName: "macwindow.on.rectangle")
                        }
                    }
                    .disabled(previewState.location == nil)
                }
                #endif
            }
        }

        #if os(macOS)
        if let _ = self.windowPreviewViewModel {
            CommandGroup(after: .importExport) {
                Button("Export Image...") {

                }
            }
        }
        #endif
    }
}

struct NodeEditCommands: Commands {

    @ActiveViewObject(AppMenuCoordinator.self) var coordinator

    var body: some Commands {
        if let coordinator = self.coordinator {
            CommandGroup(after: .textEditing) {
                let name = coordinator.nodeSelectionCount > 1 ? "Nodes" : "Node"

                #if os(iOS)
                Button("Delete \(name)") {
                    coordinator.action = .deleteSelectedNodes
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(coordinator.nodeSelectionCount == 0)
                #endif

                Button("Duplicate \(name)") {
                    coordinator.action = .duplidateSelectedNodes
                }
                .keyboardShortcut("d", modifiers: [.command])
                .disabled(coordinator.nodeSelectionCount == 0)
            }
        }
    }
}

import SwiftUI

struct PreviewFeatureCommands: Commands {

    @FocusedValue(PreviewFeatureState.self) var previewState

    #if os(macOS)
    @FocusedValue(WindowPreviewViewModel.self) var windowPreviewViewModel
    #endif

    var body: some Commands {

        CommandGroup(after: .sidebar) {
            Section {
                if let previewState = self.previewState {
                    Picker(selection: previewState.previewPositionSafeBinding) {
                        Section("Floating") {
                            Label("Top Left", systemImage: "inset.filled.topleft.rectangle")
                                .tag(PreviewPosition.topLeft)
                            Label("Top Right", systemImage: "inset.filled.topright.rectangle")
                                .tag(PreviewPosition.topRight)
                            Label("Bottom Left", systemImage: "inset.filled.bottomleft.rectangle")
                                .tag(PreviewPosition.bottomLeft)
                            Label("Bottom Right", systemImage: "inset.filled.bottomright.rectangle")
                                .tag(PreviewPosition.bottomRight)
                        }
                        Section("Docked") {
                            Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                                .tag(PreviewPosition.bottomDock)
                            Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                                .tag(PreviewPosition.topDock)
                        }
                    } label: {
                        Label("Preview Position", systemImage: "pointer.arrow.and.square.on.square.dashed")
                    }
                }
                // }
                // }

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
                            Image(systemName: "macwindow")
                        }
                    }
                }
                #endif

                #if os(macOS)
                if let previewState = self.previewState {
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

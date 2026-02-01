import Helpers
import MainViewFeature
import PreviewFeature
import SharedModels
import SwiftUI

struct PreviewFeatureCommands: Commands {

    @ActiveViewObject(GlobalCoordinator.self) var coordinator

    var body: some Commands {
        CommandGroup(after: .sidebar) {
            Section {
                if let coordinator = self.coordinator, coordinator.available.preview {
                    Menu("Preview Position") {
                        Picker("Floating", selection: coordinator.previewPositionBinding) {
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

                        Picker("Docked", selection: coordinator.previewPositionBinding) {
                            Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                                .tag(PreviewPosition.bottomDock)
                            Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                                .tag(PreviewPosition.topDock)
                        }
                        .labelsVisibility(.visible)
                        .pickerStyle(.inline)
                    }
                }

                // TODO: Make this work for both windowed and docked previews contextually
                if let coordinator = self.coordinator,
                    coordinator.previewIsDocked || coordinator.available.windowPreview
                {
                    Menu {
                        Button { [weak coordinator] in
                            coordinator?.perform(userAction: .preview(.zoomIn))
                        } label: {
                            LabeledContent("Zoom In") {
                                Image(systemName: "plus.magnifyingglass")
                            }
                        }

                        Button { [weak coordinator] in
                            coordinator?.perform(userAction: .preview(.zoomOut))
                        } label: {
                            LabeledContent("Zoom Out") {
                                Image(systemName: "minus.magnifyingglass")
                            }
                        }
                        Button { [weak coordinator] in
                            coordinator?.perform(userAction: .preview(.actualSize))
                        } label: {
                            LabeledContent("Actual Size") {
                                Image(systemName: "1.magnifyingglass")
                            }
                        }

                        Button { [weak coordinator] in
                            coordinator?.perform(userAction: .preview(.zoomToFit))
                        } label: {
                            LabeledContent("Zoom To Fit") {
                                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                            }
                        }
                    } label: {
                        Text(coordinator.available.windowPreview ? "Window Preview" : "Docked Preview")
                    }
                }

                #if os(macOS)
                if let coordinator = self.coordinator, !coordinator.available.windowPreview {
                    Button { [weak coordinator] in
                        coordinator?.perform(userAction: .preview(.openWindow))
                    } label: {
                        LabeledContent("Open Preview Window") {
                            Image(systemName: "macwindow.on.rectangle")
                        }
                    }
                }
                #endif
            }
        }

        if let coordinator = self.coordinator, coordinator.available.preview || coordinator.available.windowPreview {
            CommandGroup(after: .saveItem) {
                Button("Export Image...") { [weak coordinator] in
                    coordinator?.perform(userAction: .exportPreviewedImage)
                }
                .disabled(!(coordinator.previewHasImage || coordinator.available.windowPreview))
                .keyboardShortcut("e", modifiers: [.shift, .command])
            }
        }
    }
}

struct NodeEditCommands: Commands {

    @ActiveViewObject(GlobalCoordinator.self) var coordinator

    var body: some Commands {
        if let coordinator = self.coordinator {
            CommandGroup(after: .textEditing) {
                let name = coordinator.nodeSelectionCount > 1 ? "Nodes" : "Node"

                Button("Duplicate \(name)") { [weak coordinator = self.coordinator] in
                    coordinator?.perform(userAction: .duplicateSelectedNodes)
                }
                .keyboardShortcut("d", modifiers: [.command])
                .disabled(coordinator.nodeSelectionCount == 0)
            }
        }
    }
}

struct PasteboardCommands: Commands {

    @ActiveViewObject(GlobalCoordinator.self) var co

    var hasSelection: Bool {
        if let co {
            co.nodeSelectionCount > 0
        } else {
            false
        }
    }

    var canPaste: Bool {
        PasteboardObserver.shared.canPaste
    }

    var body: some Commands {
        CommandGroup(replacing: .pasteboard) {
            CommandButton(
                "Cut",
                systemImage: "scissors",
                action: { [weak co = self.co] in
                    co?.perform(userAction: .cutSelectedNodes)
                }
            )
            .keyboardShortcut("x", modifiers: .command)
            .disabled(!self.hasSelection)

            CommandButton(
                "Copy",
                systemImage: "document.on.document",
                action: { [weak co = self.co] in
                    co?.perform(userAction: .copySelectedNodes)
                }
            )
            .keyboardShortcut("c", modifiers: .command)
            .disabled(!self.hasSelection)

            CommandButton(
                "Paste",
                systemImage: "document.on.clipboard",
                action: { [weak co = self.co] in
                    co?.perform(userAction: .pasteNodes(nil))
                }
            )
            .keyboardShortcut("v", modifiers: .command)
            .disabled(!self.canPaste)

            CommandButton(
                "Delete",
                systemImage: "trash",
                action: { [weak co = self.co] in
                    co?.perform(userAction: .deleteSelectedNodes)
                }
            )
            .keyboardShortcut(.delete, modifiers: [])
            .disabled(!self.hasSelection)

            CommandButton(
                "Select All",
                systemImage: "character.textbox",
                action: { [weak co = self.co] in
                    co?.perform(userAction: .selectAllNodes)
                }
            )
            .keyboardShortcut("a", modifiers: .command)
        }
    }
}

struct CommandButton: View {

    let title: String
    let systemImage: String?
    let action: () -> ()

    init(_ title: String, systemImage: String?, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button {
            self.action()
        } label: {
            if let systemImage = self.systemImage {
                Label(self.title, systemImage: systemImage)
            } else {
                Text(self.title)
            }
        }
    }
}

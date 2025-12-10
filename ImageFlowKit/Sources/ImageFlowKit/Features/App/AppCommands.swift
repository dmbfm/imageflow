import SwiftUI

struct PreviewFeatureCommands: Commands {

    @FocusedValue(PreviewFeatureState<Flow, AssetStore>.self)
    var previewState: PreviewFeatureState<Flow, AssetStore>?

    var body: some Commands {
        if let previewState = self.previewState {

            @Bindable var p = previewState

            CommandGroup(after: .sidebar) {
                Section {
                    Picker(selection: $p.previewPosition) {
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
            }
        }
    }
}

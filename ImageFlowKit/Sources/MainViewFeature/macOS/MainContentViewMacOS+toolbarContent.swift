#if os(macOS)

import SharedModels
import SwiftUI


extension MainContentViewMacOS {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .secondaryAction) {
            Button {
                self.vm.coordinator.perform(userAction: .viewport(.zoomOut))
            } label: {
                Image(systemName: "minus")
            }

            Menu {
                Button("Fit Content") {
                    self.vm.coordinator.perform(userAction: .viewport(.zoomToFitContent))
                }
                .disabled(self.vm.flow.nodes.isEmpty)

                Button("Fit Selection") {
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
                HStack(alignment: .center, spacing: 2) {
                    Text(zoomFormatter.string(for: self.vm.canvas.viewport.scale) ?? "100%")
                        .frame(width: 45)
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 6)
                        .frame(height: 20)
                }
                .contentShape(.rect)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)

            Button {
                self.vm.coordinator.perform(userAction: .viewport(.zoomIn))
            } label: {
                Image(systemName: "plus")
            }
        }

        ToolbarItemGroup {

            Button("Nodes", systemImage: "list.bullet") {
                self.vm.showNodeListPopover = true
            }
            .popover(
                isPresented: self.$vm.showNodeListPopover,
                arrowEdge: .bottom,
                content: {
                    NodeListView(flow: self.vm.flow)
                }
            )

            Button("Open Asset Browser", systemImage: "photo.stack") {
                self.vm.openAssetBrowser()
            }
            .help("Open Asset Browser")
        }

        ToolbarItem {
            Button {
                self.vm.showInspector.toggle()
            } label: {
                LabeledContent("Toggle Inspector") {
                    Image(systemName: "sidebar.right")
                        .font(.system(size: 16))
                }
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .help("Toggle Inspector")
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

#endif

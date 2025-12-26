#if os(macOS)

import SwiftUI
import CIImageView

@Observable
class WindowPreviewViewModel {
    var action: CIImageScrollView.Action? = nil
    var pinned: Bool = false
}

struct WindowPreviewContentView: View {

    let location: OutputPortLocation
    let assetStore: (any AssetStoreService)
    let scrollCache: (any CIImageScrollViewCache)?
    var coordinator: PreviewWindowCoordinator? = nil
    weak var window: NSWindow? = nil

    @State var image: CIImage? = nil
    @State var zoom: CGFloat = 1.0
    @State var vm = WindowPreviewViewModel()

    class WindowDelegate: NSObject, NSWindowDelegate {
        var callback: (() -> ())?

        func windowWillClose(_ notification: Notification) {
            self.callback?()
        }
    }

    func updateWindow() {
        if self.vm.pinned {
            self.window?.level = .floating
        } else {
            self.window?.level = .normal
        }
    }

    func watchImageChanges() async {
        for await loc in self.assetStore.modifiedGeneratedAssetStream {
            if loc == self.location {
                self.startLoadingImage()
            }
        }
    }

    func startLoadingImage() {
        Task {
            await self.loadImageAsync()
        }
    }

    func loadImageAsync() async {
        do {
            let r = try await self.assetStore.getGeneratedResource(ciImageAt: self.location)
            self.image = r.res
        } catch {}
    }

    var body: some View {
        ZStack {
            Colors.canvasBackground.color

            @Bindable var vm = self.vm
            
            if let image = self.image {
                CIImageScrollView(
                    id: "",
                    image: image,
                    configuration: .init(initialViewport: .fit),
                    action: $vm.action,
                    cache: self.scrollCache,
                    zoomDidChange: { self.zoom = $0 }
                )
            }
        }
        .onChange(of: self.window, initial: true) {
            self.updateWindow()
        }
        .onChange(of: self.vm.pinned, initial: true) {
            self.updateWindow()
        }
        .onChange(of: self.location, initial: true) {
            self.startLoadingImage()
        }
        .onAppear {
            self.coordinator?.windowWillClose = { @MainActor in
                self.vm.action = .cacheSave
            }
        }
        .task {
            await self.watchImageChanges()
        }
        .toolbar {
            self.toolbarContent
        }
        .focusedSceneValue(self.vm)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .principal) {
            Button {
                self.vm.action = .zoomIn(animate: true)
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }

            Button {
                self.vm.action = .zoomOut(animate: true)
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }

            Text(zoomFormatter.string(for: self.zoom) ?? "")

            Button {
                self.vm.action = .actualSize(animate: true)
            } label: {
                Image(systemName: "1.magnifyingglass")
            }
            Button {
                self.vm.action = .zoomToFit(animate: true)
            } label: {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
            }
        }

        ToolbarItemGroup(placement: .primaryAction) {
            Button {
            } label: {
                Image(systemName: "document.on.document")
            }

            Button {

            } label: {
                Image(systemName: "square.and.arrow.down")
            }
        }

        ToolbarSpacer(.fixed)

        ToolbarItem(placement: .primaryAction) {
            Button {
                self.vm.pinned.toggle()
            } label: {
                Image(systemName: self.vm.pinned ? "pin.fill" : "pin")
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

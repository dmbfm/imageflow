#if os(macOS)

import SwiftUI
import AppKit
import SharedModels
import Helpers
import CIImageView

struct ToolbarHostingView: View {

    @Bindable var vm: ViewModel

    @Observable
    class ViewModel {
        var zoom: CGFloat
        var isPinned: Bool
        var handle: (ItemName) -> ()
        var hasImage: Bool

        var canZoomIn: Bool = true
        var canZoomOut: Bool = true
        var imageExporterState: ImageExporterState = .init()
        var error: LocalizedAlertError?

        struct ImageExporterState {
            var image: CIImage?
            var isPresented: Bool {
                get {
                    self.image != nil
                }
                set {
                    if !newValue {
                        self.image = nil
                    }
                }
            }
            var defaultFilename: String?
        }

        init(
            zoom: CGFloat,
            isPinned: Bool,
            hasImage: Bool,
            handle: @escaping (ToolbarHostingView.ItemName) -> (),
        ) {
            self.zoom = zoom
            self.isPinned = isPinned
            self.handle = handle
            self.hasImage = hasImage
        }
    }

    enum ItemName {
        case zoomIn
        case zoomOut
        case zoomActualSize
        case zoomToFit
        case copy
        case export
        case pin
    }

    var body: some View {
        EmptyView()
            .imageExporter(
                isPresented: self.$vm.imageExporterState.isPresented,
                image: self.vm.imageExporterState.image,
                defaultFilename: self.vm.imageExporterState.defaultFilename,
                errorMessage: self.$vm.error
            )
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    Button {
                        self.vm.handle(.zoomIn)
                    } label: {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    .disabled(!self.vm.canZoomIn)

                    Button {
                        self.vm.handle(.zoomOut)
                    } label: {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    .disabled(!self.vm.canZoomOut)

                    Text(zoomFormatter.string(for: self.vm.zoom) ?? "")

                    Button {
                        self.vm.handle(.zoomActualSize)
                    } label: {
                        Image(systemName: "1.magnifyingglass")
                    }
                    Button {
                        self.vm.handle(.zoomToFit)
                    } label: {
                        Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    }
                }

                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        self.vm.handle(.copy)
                    } label: {
                        Image(systemName: "document.on.document")
                    }
                    .disabled(!self.vm.hasImage)

                    Button {
                        self.vm.handle(.export)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .disabled(!self.vm.hasImage)
                }

                ToolbarSpacer(.fixed)

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        self.vm.handle(.pin)
                    } label: {
                        Image(systemName: self.vm.isPinned ? "pin.fill" : "pin")
                    }
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

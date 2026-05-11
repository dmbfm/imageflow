import CIImageView
import CardStage
import Design
import SharedModels
import SwiftUI
import XKit

#if canImport(AppKit)
import AppKit
#endif

struct DockedToolbarView: View {

    @Observable
    class ViewModel {
        var image: CIImage?
        var currentLocation: OutputPortLocation?
        var dockLocation: CardDockLocation = .bottom
        var locked: Bool = false
        var available: Set<PreviewLocation> = []
        var zoom: CGFloat = 1.0
        var dispatch: ((Action) -> ())? = nil

        internal init(
            image: CIImage? = nil,
            currentLocation: OutputPortLocation? = nil,
            dockLocation: CardDockLocation = .bottom,
            locked: Bool = false,
            available: Set<PreviewLocation> = [],
            zoom: CGFloat = 1.0,
            dispatch: ((DockedToolbarView.Action) -> ())? = nil
        ) {
            self.image = image
            self.currentLocation = currentLocation
            self.dockLocation = dockLocation
            self.locked = locked
            self.available = available
            self.zoom = zoom
            self.dispatch = dispatch
        }

    }

    enum Action {
        case pick(OutputPortLocation)
        case toggleLock
        case dockOpposite
        case openWindow
        case undock
        case copy
        case export
        case zoomIn
        case zoomOut
        case zoomActualSize
        case zoomToFit
    }

    enum DockedPreviewToolbarPlacement {
        case zstack
        case vstack
    }

    var vm: ViewModel
    let bgColor: Color = Colors.canvasBackground.color
    @Environment(\.colorScheme) var cs

    init(vm: ViewModel) {
        self.vm = vm
    }

    var zoomTextBgColor: Color {
        .init(white: cs == .dark ? 0.18 : 0.82)
    }

    var zoomText: String {
        if self.vm.image != nil {
            zoomFormatter.string(for: self.vm.zoom)!
        } else {
            ""
        }
    }

    var currentLocation: Binding<OutputPortLocation?> {
        .init(
            get: {
                self.vm.currentLocation
            },
            set: {
                if let loc = $0 {
                    self.vm.dispatch?(.pick(loc))
                }
            }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack { Spacer() }
                .frame(height: 1)
                .background(.separator)

            HStack(spacing: 8) {
                self.toolbarContentView
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 26)

            HStack { Spacer() }
                .frame(height: 1)
                .background(.separator)
        }
        .background {
            self.bgColor
        }
        .frame(height: 28)
    }

    var zoomLabel: some View {
        HStack {
            Text("\(self.zoomText)")
                .font(.caption2)
                .padding(.horizontal, 3)
                .padding(.vertical, 3)
        }
        .frame(width: 52)
        .background(self.zoomTextBgColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))

    }

    @ViewBuilder
    var toolbarContentView: some View {
        HStack(spacing: 8) {
            btn(self.vm.locked ? "lock.fill" : "lock") {
                self.vm.dispatch?(.toggleLock)
            }
            .disabled(self.vm.image == nil)

            VDivider()

            btn(
                self.vm.dockLocation == .bottom ? "inset.filled.tophalf.rectangle" : "inset.filled.bottomhalf.rectangle"
            ) {
                self.vm.dispatch?(.dockOpposite)
            }

            btn("macwindow.on.rectangle") {
                self.vm.dispatch?(.openWindow)
            }
            .disabled(self.vm.image == nil)

            btn("pip.enter") {
                self.vm.dispatch?(.undock)
            }

            Spacer()

            Spacer()

            if self.vm.available.count >= 2 {
                Image(systemName: "photo.stack.fill")
                    .padding(.trailing, -6)

                Picker("", selection: self.currentLocation) {
                    ForEach(Array(self.vm.available), id: \.self) { item in
                        Text("\(item.name)")
                            .tag(item.location)
                    }
                }
            }

            btn("document.on.document") {
                self.vm.dispatch?(.copy)
            }

            VDivider()

            btn("square.and.arrow.down") {
                self.vm.dispatch?(.export)
            }
            .disabled(self.vm.image == nil)
        }
        .overlay(alignment: .center) {
            HStack(spacing: 8) {
                Group {
                    btn("plus.magnifyingglass") {
                        self.vm.dispatch?(.zoomIn)
                    }
                    .disabled(self.vm.image == nil)

                    btn("minus.magnifyingglass") {
                        self.vm.dispatch?(.zoomOut)
                    }
                    .disabled(self.vm.image == nil)

                    self.zoomLabel

                    btn("1.magnifyingglass") {
                        self.vm.dispatch?(.zoomActualSize)
                    }
                    .disabled(self.vm.image == nil)

                    btn("arrow.up.left.and.down.right.magnifyingglass") {
                        self.vm.dispatch?(.zoomToFit)
                    }
                    .disabled(self.vm.image == nil)
                }
            }
        }
    }

    @MainActor
    private func btn(_ icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
        }
        .buttonStyle(.plain)
    }
}

private struct VDivider: View {
    var body: some View {
        Divider().frame(width: 1, height: 14)
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

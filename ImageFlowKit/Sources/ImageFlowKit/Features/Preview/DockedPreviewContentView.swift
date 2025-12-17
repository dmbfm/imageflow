import CIImageView
import Controls
import CoreImage
import Helpers
import SwiftUI

struct DockedPreviewContentView: View {

    let vm: PreviewContentViewModel
    var dispatch: ((PreviewContentViewAction) -> ())?

    @State var zoom: CGFloat = 1.0
    @State var action: CIImageScrollView.Action? = nil

    @Environment(\.colorScheme) var cs

    let bgColor: Color = Colors.canvasBackground.color
    let divColor: Color = Colors.canvasBackgroundDot.color
    let toolbarHeight: CGFloat = 26.0

    enum Action {
        case undock
        case toggleLock
    }

    var zoomTextBgColor: Color {
        .init(white: cs == .dark ? 0.18 : 0.82)
    }

    var zoomText: String {
        zoomFormatter.string(for: self.zoom)!
    }

    var body: some View {
        VStack(spacing: 0) {
            if self.vm.dockLocation == .up {
                self.contentView
                self.toolbarView
            } else {
                self.toolbarView
                self.contentView
            }
        }
        .background {
            self.bgColor
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch vm.content {
        case .image(let image):
            CIImageScrollView(
                image: image,
                configuration: .init(),
                zoom: $zoom,
                action: $action
            )
        default:
            ZStack {
                Color.clear
                ContentUnavailableView(
                    "No Image",
                    systemImage: "photo",
                    description: Text("Select a node with an output image to preview!")
                )
            }
        }
    }

    @ViewBuilder
    var toolbarView: some View {
        VStack(spacing: 0) {
            sep
            HStack(spacing: 8) {
                self.toolbarContentView
            }
            .padding(.horizontal, 10)
            .frame(height: self.toolbarHeight)
            .frame(maxWidth: .infinity)
            .background {
                self.bgColor
            }

            sep
        }
    }

    @ViewBuilder
    var toolbarContentView: some View {
        HStack(spacing: 8) {
            btn(self.vm.isLocked ? "lock.fill" : "lock") {
                self.dispatch?(.toggleLock)
            }
            .disabled(self.vm.lockButtonDisabled)

            self.vsep

            btn(self.vm.dockLocation == .down ? "inset.filled.tophalf.rectangle" : "inset.filled.bottomhalf.rectangle")
            {
                self.dispatch?(.dockOpposite)
            }

            btn("pip.enter") {
                self.dispatch?(.undock)
            }

            Spacer()

            Spacer()

            btn("square.and.arrow.down") {
            }
        }
        .overlay(alignment: .center) {
            HStack(spacing: 8) {
                Group {
                    btn("plus.magnifyingglass") {
                        self.action = .zoomIn(animate: true)
                    }

                    btn("minus.magnifyingglass") {
                        self.action = .zoomOut(animate: true)
                    }

                    self.zoomLabel

                    btn("1.magnifyingglass") {
                        self.action = .actualSize(animate: true)
                    }

                    btn("arrow.up.left.and.down.right.magnifyingglass") {
                        self.action = .zoomToFit(animate: true)
                    }
                }
            }
        }
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

    var sep: some View {
        self.divColor
            .frame(height: 1)
    }

    var vsep: some View {
        Divider().frame(width: 1, height: 14)
    }

}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()

@MainActor
func btn(_ icon: String, action: @escaping () -> ()) -> some View {
    Button {
        action()
    } label: {
        Image(systemName: icon)
    }
    .buttonStyle(.plain)
}

#Preview {
    VStack(spacing: 0) {
        Colors.canvasBackground.color
            .frame(height: 150)
        DockedPreviewContentView(
            vm: .init(
                content: .image(.blue.cropped(to: .init(x: 0, y: 0, width: 256, height: 256))),
                isLocked: false,
                lockButtonDisabled: false
            )
        )
        .clipped()
    }

}
